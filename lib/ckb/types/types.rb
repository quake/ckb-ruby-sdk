module CKB
  module Types

    class HexStringInitializeArray < Array
      def initialize(value)
        super(
          if value.is_a?(String)
            [value[2..-1]].pack("H*").bytes
          else
            value
          end
        )
      end

      def as_json
        "0x#{self.pack("c*").unpack("H*").first}"
      end
    end

    class H256 < HexStringInitializeArray
      def serialize
        self
      end
    end

    class Bytes < HexStringInitializeArray
      def serialize
        [size].u32_serialize + self
      end
    end

  end
end

class Integer
  def u32_serialize
    [self].u32_serialize
  end

  def u64_serialize
    [self].u64_serialize
  end

  def as_json
    "0x%x" % self
  end
end

class Array
  def u32_serialize
    pack("L<*").bytes
  end

  def u64_serialize
    pack("Q<*").bytes
  end

  # https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0008-serialization/0008-serialization.md#vectors
  def fixvec_serialize
    [self.size].u32_serialize + self.map(&:serialize).flatten
  end

  def dynvec_serialize
    body = self.map {|a| a.class == Array ? a : a.serialize }
    header_size = (1 + body.size) * 4
    header = [header_size + body.map(&:size).sum] + body[0...-1].inject([header_size]) {|offsets, a| offsets.push(offsets.last + a.size)}
    header.u32_serialize + body.flatten
  end
end

class String
  def to_hex
    "0x#{self.unpack("H*").first}"
  end

  def from_hex
    [self.delete_prefix("0x")].pack("H*")
  end
end

require_relative "hash_initialize"
require_relative "out_point"
require_relative "cell_dep"
require_relative "script"
require_relative "input"
require_relative "output"
require_relative "transaction"
require_relative "witness_args"
