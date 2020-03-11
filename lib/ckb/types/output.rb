module CKB
  module Types
    class Output
      extend HashInitialize
      hash_initialize capacity: :u64,
                      lock:     CKB::Types::Script,
                      type:     CKB::Types::Script

      def serialize
        [capacity.u64_serialize, lock.serialize, type.nil? ? [] : type.serialize].dynvec_serialize
      end

      # https://github.com/nervosnetwork/ckb/wiki/Occupied-Capacity
      def occupied_capacity(data)
        (8 + data.size + lock.occupied_capacity + (type.nil? ? 0 : type.occupied_capacity)) * 1_0000_0000
      end
    end
  end
end
