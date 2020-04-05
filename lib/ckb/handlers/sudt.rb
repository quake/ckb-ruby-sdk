module CKB
  module Handlers
    class Sudt
      attr_accessor :cell_dep

      def initialize(sudt_tx_hash)
        self.cell_dep =  CKB::Types::CellDep.new(
          out_point: CKB::Types::OutPoint.new(tx_hash: sudt_tx_hash, index: 0),
          dep_type: CKB::Types::CellDep::DEP_TYPE_CODE
        )
      end

      def generate(cell_meta_or_output_index, tx_builder)
        tx_builder.transaction.cell_deps << cell_dep unless tx_builder.transaction.cell_deps.include?(cell_dep)
      end

      def sign(cell_meta_or_output_index, tx_builder)
        # do nothing
      end
    end
  end
end