module CKB
  module Types
    class Transaction
      extend HashInitialize
      hash_initialize version:      :u32,
                      cell_deps:    [CKB::Types::CellDep],
                      header_deps:  [CKB::Types::H256],
                      inputs:       [CKB::Types::Input],
                      outputs:      [CKB::Types::Output],
                      outputs_data: [CKB::Types::Bytes],
                      witnesses:    [CKB::Types::Bytes]

      def serialize
        [raw_serialize, witnesses.dynvec_serialize].dynvec_serialize
      end

      def raw_serialize
        [
          [version].u32_serialize, cell_deps.fixvec_serialize, header_deps.fixvec_serialize,
          inputs.fixvec_serialize, outputs.dynvec_serialize, outputs_data.dynvec_serialize
        ].dynvec_serialize
      end

      def compute_hash
        @compute_hash ||= CKB::Blake2b.digest(self.raw_serialize.pack("C*"))
      end

      def compute_witness_hash
        @compute_witness_hash ||= CKB::Blake2b.digest(self.serialize.pack("C*"))
      end

      def outputs_capacity
        outputs.sum(&:capacity)
      end

      def serialized_size_in_block
        self.serialize.size + 4
      end
    end
  end
end
