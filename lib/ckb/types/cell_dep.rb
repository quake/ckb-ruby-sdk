module CKB
  module Types
    class CellDep
      DEP_TYPE_CODE = :code
      DEP_TYPE_DEP_GROUP = :dep_group

      extend HashInitialize
      hash_initialize out_point: CKB::Types::OutPoint,
                      dep_type:  :enum

      def serialize
        out_point.serialize + [dep_type == DEP_TYPE_CODE ? 0 : 1]
      end

      def self.standard_secp256k1_blake160_sighash_all(genesis_block)
        CellDep.new(
          out_point: CKB::Types::OutPoint.new(tx_hash: CKB::Types::Transaction.new(genesis_block[:transactions][1]).compute_hash.to_hex, index: 0),
          dep_type: CellDep::DEP_TYPE_DEP_GROUP
        )
      end

      def self.standard_secp256k1_blake160_multisig_all(genesis_block)
        CellDep.new(
          out_point: CKB::Types::OutPoint.new(tx_hash: CKB::Types::Transaction.new(genesis_block[:transactions][1]).compute_hash.to_hex, index: 1),
          dep_type: CellDep::DEP_TYPE_DEP_GROUP
        )
      end
    end
  end
end
