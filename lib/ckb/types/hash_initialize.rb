module CKB
  module Types
    module HashInitialize
      def hash_initialize(attributes)
        attr_accessor(*attributes.keys)

        define_method :initialize do |h|
          h.keep_if {|k, v| attributes.include?(k)}.each do |k, v|
            attr_type = attributes[k]
            _v = if attr_type.is_a?(Array)
              clazz = attr_type.first
              v.map {|a| a.is_a?(clazz) ? a : clazz.new(a)}
            elsif [CKB::Types::H256, CKB::Types::Bytes].include?(attr_type)
              attr_type.new(v)
            elsif [:u32, :u64].include?(attr_type)
              Integer(v)
            elsif attr_type == :enum
              v.to_sym
            else
              if v.is_a?(Hash)
                attr_type.new(v)
              else
                v
              end
            end
            public_send("#{k}=", _v)
          end
        end

        define_method :as_json do
          (self.instance_variables - [:@compute_hash]).each_with_object({}) do |attr, h|
            value = self.instance_variable_get(attr)
            unless value.nil?
              _v = if value.is_a?(Array)
                if value.empty?
                  []
                elsif value.first.is_a?(Integer)
                  "0x#{value.pack("c*").unpack("H*").first}"
                else
                  value.map(&:as_json)
                end
              elsif value.is_a?(Hash)
                Hash[value.map { |k, v| [k, v.as_json] }]
              elsif value.is_a?(Symbol)
                value.to_s
              else
                value.as_json
              end
              h[attr.to_s.delete_prefix("@")] = _v
            end
          end
        end

        define_method :variables do
          (self.instance_variables - [:@compute_hash]).map { |attr| self.instance_variable_get attr }
        end

        define_method :== do |other|
          other.class == self.class && other.variables == self.variables
        end

        define_method :hash do
          self.variables.hash
        end

        define_method :eql? do |other|
          other.class == self.class && other.hash == self.hash
        end
      end
    end
  end
end
