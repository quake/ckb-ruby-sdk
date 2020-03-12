require "ckb/version"
require "ckb/blake2b"
require "ckb/types/types"
require "ckb/cell_meta"
require "ckb/config"
require "ckb/address"
require "ckb/rpc"
require "ckb/collector"
require "ckb/transaction_builder"
require "ckb/wallet"

module CKB
  MAINNET = :mainnet
  TESTNET = :testnet

  @@network = MAINNET

  def self.network=(value)
    @@network = value
  end

  def self.network
    @@network
  end
end