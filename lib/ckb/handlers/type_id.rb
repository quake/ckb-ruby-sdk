module CKB
  module Handlers
    class TypeId
      def generate(cell_meta, tx_builder)
        # do nothing
      end

      def generate_with_output(index, tx_builder)
        tx_builder.transaction.outputs[index].type.args = CKB::Types::Bytes.new(Array.new(32, 0))
      end

      def sign(cell_meta, tx_builder)
        # do nothing
      end

      def sign_with_output(index, tx_builder)
        blake2b = CKB::Blake2b.new
        blake2b << tx_builder.transaction.inputs.first.serialize
        blake2b << index.u64_serialize
        tx_builder.transaction.outputs[index].type.args = CKB::Types::Bytes.new(blake2b.digest.to_hex)
      end
    end
  end
end