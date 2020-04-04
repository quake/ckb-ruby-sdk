module CKB
  module Handlers
    class TypeId
      def generate(cell_meta, tx_builder)
        # do nothing
      end

      def sign(cell_meta, tx_builder)
        type = cell_meta.output.type
        output_index = tx_builder.transaction.outputs.find_index{|output| output.type == type}

        blake2b = CKB::Blake2b.new
        blake2b << tx_builder.transaction.inputs.first.serialize
        blake2b << output_index.u64_serialize
        tx_builder.transaction.outputs[output_index].type.args = CKB::Types::Bytes.new(blake2b.digest.to_hex)
      end
    end
  end
end