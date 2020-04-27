module CKB
  class TransactionBuilder
    attr_accessor :transaction, :cell_metas

    def initialize(h)
      self.transaction = CKB::Types::Transaction.new(h)
      self.cell_metas= []
    end

    # Generate unsigned transaction
    # @param collector [Enumerator] `CellMeta` enumerator
    # @param contexts  [Hash], key: input lock script, value: tx generating context
    # @param fee_rate  [Integer] Default 1 shannon / transaction byte
    def generate(collector, contexts, fee_rate = 1)
      # run outputs type script handler
      self.transaction.outputs.each_with_index do |output, index|
        if type_script = output.type
          if type_handler = CKB::Config.instance.type_handler(type_script)
            type_handler.generate_with_output(index, self)
          end
        end
      end

      change_capacity_output_index = self.transaction.outputs.find_index {|output| output.capacity == 0 && output.type.nil?}
      # run inputs lock and type script handler
      collector.each do |cell_meta|
        lock_script, type_script = cell_meta.output.lock, cell_meta.output.type
        lock_handler = CKB::Config.instance.lock_handler(lock_script)
        lock_handler.generate(cell_meta, self, contexts[lock_script])
        if type_script
          type_handler = CKB::Config.instance.type_handler(type_script)
          type_handler.generate(cell_meta, self)
        end
        return if self.enough_capacity?(change_capacity_output_index, fee_rate)
      end

      raise "can't collect enough inputs"
    end

    def enough_capacity?(change_capacity_output_index, fee_rate)
      # calculate fee and update change output capacity
      fee = self.transaction.serialized_size_in_block * fee_rate
      change_capacity = self.inputs_capacity - self.transaction.outputs_capacity - fee
      if change_capacity_output_index
        change_output = self.transaction.outputs[change_capacity_output_index]
        change_output_data = self.transaction.outputs_data[change_capacity_output_index]
        if change_capacity >= change_output.occupied_capacity(change_output_data)
          change_output.capacity = change_capacity
          true
        end
      else
        if change_capacity > 0
          raise "cannot find change output"
        elsif change_capacity == 0
          true
        end
      end
    end

    # @param contexts  [Hash], key: input lock script, value: tx signature context
    def sign(contexts)
      # run outputs type script handler
      self.transaction.outputs.each_with_index do |output, index|
        if type_script = output.type
          if type_handler = CKB::Config.instance.type_handler(type_script)
            type_handler.sign_with_output(index, self)
          end
        end
      end

      # run inputs lock and type script handler
      self.cell_metas.each do |cell_meta|
        lock_script, type_script = cell_meta.output.lock, cell_meta.output.type
        lock_handler = CKB::Config.instance.lock_handler(lock_script)
        if context = contexts[lock_script]
          lock_handler.sign(cell_meta, self, context)
        end
        if type_script
          type_handler = CKB::Config.instance.type_handler(type_script)
          type_handler.sign(cell_meta, self)
        end
      end
    end

    def inputs_capacity
      cell_metas.map{|cm| cm.output.capacity}.sum
    end
  end
end
