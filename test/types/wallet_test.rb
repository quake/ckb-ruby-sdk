require "test_helper"

class WalletTest < Minitest::Test
  # addresses `ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37` / `ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4`
  # and corresponding private keys are copied from dev chain genesis block's issued_cells:
  # https://github.com/nervosnetwork/ckb/blob/develop/resource/specs/dev.toml#L70
  #
  # `ckt1qyq6tkfaxx9dupue4k06m3hfsz7l7p69nzkqmx27vt` is a multisig address generated by
  # ./ckb-cli tx build-multisig-address --sighash-address ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37 --sighash-address ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4 --threshold 2

  def test_gen_tx_by_default_scanner
    rpc = CKB::RPC.new
    wallet = CKB::Wallet.new(rpc)
    # transfer 421 ckb to multisig address
    tx = wallet.gen_tx(
      "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37",
      "ckt1qyq6tkfaxx9dupue4k06m3hfsz7l7p69nzkqmx27vt",
      421_0000_0000,
      "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc".from_hex
    )
    rpc.send_transaction(tx.as_json)
  end

  def test_gen_tx_by_default_indexer
    rpc = CKB::RPC.new
    wallet = CKB::Wallet.new(rpc, :default_indexer)
    # transfer 421 ckb to multisig address
    tx = wallet.gen_tx(
      "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37",
      "ckt1qyq6tkfaxx9dupue4k06m3hfsz7l7p69nzkqmx27vt",
      421_0000_0000,
      "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc".from_hex
    )
    rpc.send_transaction(tx.as_json)
  end

  def test_gen_multisig_tx
    rpc = CKB::RPC.new
    wallet = CKB::Wallet.new(rpc)
    # transfer 124 ckb from multisig address
    tx = wallet.gen_tx(
      "ckt1qyq6tkfaxx9dupue4k06m3hfsz7l7p69nzkqmx27vt",
      "ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4",
      124_0000_0000,
      [0, 0, 2, 2, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc".from_hex, "0x63d86723e08f0f813a36ce6aa123bb2289d90680ae1e99d4de8cdb334553f24d".from_hex]
    )
    rpc.send_transaction(tx.as_json)
  end
end
