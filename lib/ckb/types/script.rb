module CKB
  module Types
    class Script
      HASH_TYPE_DATA = :data
      HASH_TYPE_TYPE = :type

      # https://github.com/nervosnetwork/ckb/blob/develop/resource/specs/mainnet.toml#L73
      SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH = ["9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8"].pack("H*").bytes
      # https://github.com/nervosnetwork/ckb/blob/develop/resource/specs/mainnet.toml#L127
      SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH = ["5c5069eb0857efc65e1bca0c07df34c31663b3622fd3876c876320fc9634e2a8"].pack("H*").bytes

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
