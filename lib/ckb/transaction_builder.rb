module CKB
  class TransactionBuilder
    attr_accessor :transaction, :rpc, :cell_metas

    def initialize(h, rpc)
      self.transaction = CKB::Types::Transaction.new(h)
      self.rpc = rpc
      self.cell_metas= []
    end

    # Generate unsigned transaction
    # @param collector [Enumerator] `CellMeta` enumerator
    # @param contexts  [Hash]
    # @param fee_rate  [Integer] Default 1 shannon / transaction byte
    def generate(collector, contexts, fee_rate = 1)
      collector.each do |cell_meta|
        cell_meta.generate(self, contexts[cell_meta.output.lock])

        fee = self.transaction.serialized_size_in_block * fee_rate
        change_capacity = self.inputs_capacity - self.transaction.outputs_capacity - fee
        if change_capacity > 0
          change_output_index = self.transaction.outputs.find_index {|output| output.capacity == 0}
          if change_output_index
            self.transaction.outputs[change_output_index].capacity = change_capacity
            self.transaction
          else
            raise "cannot find change output"
          end
        elsif change_capacity == 0
          self.transaction
        end
      end
    end

    def sign(contexts)
      self.cell_metas.each do |cell_meta|
        cell_meta.sign(self, contexts[cell_meta.output.lock])
      end
    end

    def inputs_capacity
      cell_metas.map{|cm| cm.output.capacity}.sum
    end
  end
end
