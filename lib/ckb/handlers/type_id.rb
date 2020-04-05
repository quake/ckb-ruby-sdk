module CKB
  module Handlers
    class TypeId
      def generate(cell_meta_or_output_index, tx_builder)
        if cell_meta_or_output_index.is_a?(Integer)
          tx_builder.transaction.outputs[cell_meta_or_output_index].type.args = CKB::Types::Bytes.new(Array.new(32, 0))
        end
      end

      def sign(cell_meta_or_output_index, tx_builder)
        if cell_meta_or_output_index.is_a?(Integer)
          output_index = cell_meta_or_output_index

          blake2b = CKB::Blake2b.new
          blake2b << tx_builder.transaction.inputs.first.serialize
          blake2b << output_index.u64_serialize
          tx_builder.transaction.outputs[output_index].type.args = CKB::Types::Bytes.new(blake2b.digest.to_hex)
        end
      end
    end
  end
end