require "test_helper"

class SudtWalletTest < Minitest::Test
  # deploy sudt and get tx hash
  # ```
  # wallet = CKB::Wallet.new("ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
  # data = File.read("/your-path-to/ckb-miscellaneous-scripts/build/simple_udt").unpack("C*")
  # tx_builder = wallet.build("ckt1qgqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqparrr6", 1800_0000_0000, {data: data})
  # tx = wallet.sign(tx_builder, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc".from_hex)
  # rpc = CKB::Config.instance.rpc
  # rpc.send_transaction(tx.as_json)
  # ```
  # => 0xa5ecbaf702d3feef653f52867a0a7c9f2c872f043a0e5e7a81e29c58e9c4f084
  #
  def setup
    CKB::Config.instance.type_handlers[[CKB::SudtWallet::SUDT_CODE_HASH, CKB::Types::Script::HASH_TYPE_DATA]] = CKB::Handlers::Sudt.new("0xa5ecbaf702d3feef653f52867a0a7c9f2c872f043a0e5e7a81e29c58e9c4f084")
  end

  # `0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947` is the script hash of `ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37`
  def test_sudt_issue
    wallet = CKB::SudtWallet.new("ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37", "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    # issue 1000_0000 sudt to `ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4`
    tx_builder = wallet.build("ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4", 1000_0000)
    tx = wallet.sign(tx_builder, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc".from_hex)
    rpc = CKB::Config.instance.rpc
    rpc.send_transaction(tx.as_json)
  end

  def test_sudt_transfer
    wallet = CKB::SudtWallet.new("ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4", "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    # transfer 9999 sudt to `ckt1qyqr8ljpvy6y7t0cp2m0prv2whvm05whjzeqaydfze`
    tx_builder = wallet.build("ckt1qyqr8ljpvy6y7t0cp2m0prv2whvm05whjzeqaydfze", 9999)
    tx = wallet.sign(tx_builder, "0x63d86723e08f0f813a36ce6aa123bb2289d90680ae1e99d4de8cdb334553f24d".from_hex)
    rpc = CKB::Config.instance.rpc
    rpc.send_transaction(tx.as_json)
  end
end
