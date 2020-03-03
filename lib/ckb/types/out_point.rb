module CKB
  module Types
    class OutPoint
      extend HashInitialize
      hash_initialize tx_hash: CKB::Types::H256,
                      index:   :u32

      def serialize
        tx_hash.serialize + index.u32_serialize
      end
    end
  end
end
