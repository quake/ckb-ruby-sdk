require 'singleton'

module CKB
  class Config
    include Singleton
    attr_accessor :cell_meta_handlers
    attr_reader :rpc_uri, :rpc

    def initialize
      self.cell_meta_handlers = {
        [CKB::Types::Script::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, CKB::Types::Script::HASH_TYPE_TYPE] => CKB::CellMeta::DefaultSighash,
        [CKB::Types::Script::SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH, CKB::Types::Script::HASH_TYPE_TYPE] => CKB::CellMeta::DefaultMultisig
      }
      self.rpc_uri = "http://127.0.0.1:8114"
    end

    def cell_meta_handler(cell_meta)
      self.cell_meta_handlers[[cell_meta.output.lock.code_hash, cell_meta.output.lock.hash_type]]
    end

    def rpc_uri=(rpc_uri)
      @rpc_uri = rpc_uri
      @rpc = CKB::RPC.new(@rpc_uri)
    end
  end
end