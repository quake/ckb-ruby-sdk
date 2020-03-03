module CKB
  module Types
    class Input
      extend HashInitialize
      hash_initialize since:           :u64,
                      previous_output: CKB::Types::OutPoint

      def serialize
        since.u64_serialize + previous_output.serialize
      end
    end
  end
end
