require "rbnacl"

module CKB
  class Blake2b
    DEFAULT_OPTIONS = {
      personal: "ckb-default-hash",
      digest_size: 32
    }

    def initialize
      @blake2b = RbNaCl::Hash::Blake2b.new(DEFAULT_OPTIONS)
    end

    def update(message)
      if message.is_a?(Array)
        @blake2b.update(message.pack("c*"))
      else
        @blake2b.update(message)
      end
      self
    end

    alias << update

    def digest
      @blake2b.digest
    end

    def self.digest(message)
      RbNaCl::Hash::Blake2b.digest(message, DEFAULT_OPTIONS)
    end
  end
end
