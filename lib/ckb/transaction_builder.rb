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
      change_output_index = self.transaction.outputs.find_index {|output| output.capacity == 0}

      collector.each do |cell_meta|
        handler = CKB::Config.instance.cell_meta_handler(cell_meta)
        handler.generate(cell_meta, self, contexts[cell_meta.output.lock])
        return if self.enough_capacity?(change_output_index, fee_rate)
      end

      raise "can't collect enough inputs"
    end

    def enough_capacity?(change_output_index, fee_rate)
      # calculate fee and update change output capacity
      fee = self.transaction.serialized_size_in_block * fee_rate
      change_capacity = self.inputs_capacity - self.transaction.outputs_capacity - fee
      if change_output_index
        change_output = self.transaction.outputs[change_output_index]
        change_output_data = self.transaction.outputs_data[change_output_index]
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
      self.cell_metas.each do |cell_meta|
        handler = CKB::Config.instance.cell_meta_handler(cell_meta)
        if context = contexts[cell_meta.output.lock]
          handler.sign(cell_meta, self, context)
        end
      end
    end

    def inputs_capacity
      cell_metas.map{|cm| cm.output.capacity}.sum
    end
  end
end
