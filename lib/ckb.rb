require "ckb/version"
require "ckb/blake2b"
require "ckb/types/types"
require "ckb/address"
require "ckb/rpc"
require "ckb/cell_meta"
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

# rpc = CKB::RPC::new
# tip_header = rpc.get_tip_header
#
# wallet = CKB::Wallet::new
# tx = wallet.gen_tx("ckbxxx", "ckbxxx", 100)
# signer = CKB::Signer::new("0x...private_key...")
# signed_tx = signer.sign(tx)
# rpc.send_transaction(signed_tx)



# rpc = CKB::RPC.new("http://127.0.0.1:8114")
# wallet = CKB::Wallet.new(rpc)
# tx = wallet.gen_tx("ckbxxx1", "ckbxxx2", 100)
# signed_tx = CKB::Signer.sign(tx, private_key)
# rpc.send_transaction(signed_tx)


# tx = wallet.gen_tx(["ckbxxx1", "ckbxxx2"], ["ckbxxx3": 100, "ckbxxx4": 200])
