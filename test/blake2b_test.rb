require "test_helper"

class Blake2bTest < Minitest::Test
  # https://github.com/nervosnetwork/ckb/wiki/ckbhash
  def test_empty_string
    assert_equal "0x44f4c69744d5f8c55d642062949dcae49bc4e7ef43d388c5a12f42b5633d163e", CKB::Blake2b.digest("").to_hex
  end

  def test_stream_update
    blake2b = CKB::Blake2b.new
    blake2b.update("Hello")
    blake2b.update(" World!")

    assert_equal CKB::Blake2b.digest("Hello World!"), blake2b.digest
  end
end
