require "test_helper"

class WalletTest < Minitest::Test
  def test_gen_tx_default_scanner
    rpc = CKB::RPC.new
    wallet = CKB::Wallet.new(rpc)
    tx = wallet.gen_tx(
      "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37",
      "ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4",
      100_0000_0000,
      "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc".from_hex
    )
    rpc.send_transaction(tx.as_json)
  end

  def test_gen_tx_default_indexer
    rpc = CKB::RPC.new
    wallet = CKB::Wallet.new(rpc, :default_indexer)
    tx = wallet.gen_tx(
      "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37",
      "ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4",
      100_0000_0000,
      "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc".from_hex
    )
    rpc.send_transaction(tx.as_json)
  end
end
