module CKB
  module Types
    class WitnessArgs
      extend HashInitialize
      hash_initialize lock:        CKB::Types::Bytes,
                      input_type:  CKB::Types::Bytes,
                      output_type: CKB::Types::Bytes

      def serialize
        [
          lock.nil? ? [] : lock.serialize,
          input_type.nil? ? [] : input_type.serialize,
          output_type.nil? ? [] : output_type.serialize
        ].dynvec_serialize
      end

    end
  end
end
