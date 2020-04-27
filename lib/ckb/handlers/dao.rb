module CKB
  module Handlers
    class Dao
      def generate(cell_meta_or_output_index, tx_builder)
        cell_dep = CKB::Types::CellDep.dao
        tx_builder.transaction.cell_deps << cell_dep unless tx_builder.transaction.cell_deps.include?(cell_dep)
        # if cell_meta_or_output_index.is_a?(Integer)
        #   # https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0023-dao-deposit-withdraw/0023-dao-deposit-withdraw.md#deposit
        #   is_deposit = tx_builder.transaction.outputs_data[cell_meta_or_output_index] == CKB::Types::Bytes.new(Array.new(8, 0))

        #   if is_deposit
        #     tx_builder.transaction.outputs_data[cell_meta_or_output_index] = CKB::Types::Bytes.new(Array.new(8, 0))
        #   end
        # else
        #   # https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0023-dao-deposit-withdraw/0023-dao-deposit-withdraw.md#withdraw-phase-1
        #   tx_builder.transaction.outputs_data[cell_meta_or_output_index] = CKB::Types::Bytes.new(Array.new(8, 0))
        # end
      end

      def sign(cell_meta_or_output_index, tx_builder)

      end
    end
  end
end