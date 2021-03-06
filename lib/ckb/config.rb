require 'singleton'

module CKB
  class Config
    include Singleton
    attr_accessor :lock_handlers, :type_handlers
    attr_reader :rpc_uri, :rpc

    def initialize
      self.lock_handlers = {
        [CKB::Types::Script::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, CKB::Types::Script::HASH_TYPE_TYPE] => CKB::Handlers::DefaultSighash.new,
        [CKB::Types::Script::SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH, CKB::Types::Script::HASH_TYPE_TYPE] => CKB::Handlers::DefaultMultisig.new
      }
      self.type_handlers = {
        [CKB::Types::Script::DAO_TYPE_HASH, CKB::Types::Script::HASH_TYPE_TYPE] => CKB::Handlers::Dao.new,
        [CKB::Types::Script::TYPE_ID_HASH, CKB::Types::Script::HASH_TYPE_TYPE] => CKB::Handlers::TypeId.new
      }
      self.rpc_uri = "http://127.0.0.1:8114"
    end

    def lock_handler(lock_script)
      self.lock_handlers[[lock_script.code_hash, lock_script.hash_type]]
    end

    def type_handler(type_script)
      self.type_handlers[[type_script.code_hash, type_script.hash_type]]
    end

    def rpc_uri=(rpc_uri)
      @rpc_uri = rpc_uri
      @rpc = CKB::RPC.new(@rpc_uri)
    end
  end
end