module CKB
  module Types
    class Script
      HASH_TYPE_DATA = :data
      HASH_TYPE_TYPE = :type

      # https://github.com/nervosnetwork/ckb/blob/develop/docs/hashes.toml#L13
      SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH = "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8".from_hex.bytes
      # https://github.com/nervosnetwork/ckb/blob/develop/docs/hashes.toml#L33
      SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH = "0x5c5069eb0857efc65e1bca0c07df34c31663b3622fd3876c876320fc9634e2a8".from_hex.bytes
      # https://github.com/nervosnetwork/ckb/blob/develop/docs/hashes.toml#L20
      DAO_TYPE_HASH = "0x82d76d1b75fe2fd9a27dfbaa65a039221a380d76c926f378d3f81cf3e7e13f2e".from_hex.bytes
      # https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0022-transaction-structure/0022-transaction-structure.md#type-id
      # The Type ID code cell uses a special type script hash, which is just the ascii codes in hex of the text TYPE_ID.
      TYPE_ID_HASH = "0x00000000000000000000000000000000000000000000000000545950455f4944".from_hex.bytes

      extend HashInitialize
      hash_initialize code_hash: CKB::Types::H256,
                      args:      CKB::Types::Bytes,
                      hash_type: :enum

      def compute_hash
        @compute_hash ||= CKB::Blake2b.digest(serialize.pack("C*"))
      end

      def serialize
        [code_hash.serialize, [hash_type == HASH_TYPE_DATA ? 0 : 1], args.serialize].dynvec_serialize
      end

      # https://github.com/nervosnetwork/ckb/wiki/Occupied-Capacity
      def occupied_capacity
        args.size + 32 + 1
      end
    end
  end
end
