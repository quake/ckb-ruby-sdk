require "test_helper"

class DaoWalletTest < Minitest::Test
  def test_deposit
    wallet = CKB::Wallets::Dao.new("ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
    tx_builder = wallet.build("ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37", 2000_0000_0000)
    tx = wallet.sign(tx_builder, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc".from_hex)

    rpc = CKB::Config.instance.rpc
    tx_hash = rpc.send_transaction(tx.as_json)
    puts tx_hash
  end

  def test_claim
    # tx_hash => 0x152c9c2e17cde2b1f13d85e08c3a489c15463cdad4055eef7d864adf65e0b3ef
    # wallet = CKB::Wallets::Dao.new("ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
    # tx_builder = wallet.build_wi
  end

  def test_withdraw
  end
end