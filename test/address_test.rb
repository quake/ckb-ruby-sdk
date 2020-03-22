require "test_helper"

class AddressTest < Minitest::Test
  def test_short_payload_generate
    script = {
      code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
      args:      "0x36c329ed630d6ce750712a477543672adab57f4c",
      hash_type: "type"
    }
    assert_equal "ckb1qyqrdsefa43s6m882pcj53m4gdnj4k440axqdt9rtd", CKB::Address.generate(script)
    assert_equal "ckt1qyqrdsefa43s6m882pcj53m4gdnj4k440axqswmu83", CKB::Address.generate(script, CKB::Address::HRP_TESTNET)

    script = {
      code_hash: "0x5c5069eb0857efc65e1bca0c07df34c31663b3622fd3876c876320fc9634e2a8",
      args:      "0xf04cec84bc37f683613bed2f242c9aa1b678e9fe",
      hash_type: "type"
    }
    assert_equal "ckb1qyqlqn8vsj7r0a5rvya76tey9jd2rdnca8lq2sg8su", CKB::Address.generate(script)
    assert_equal "ckt1qyqlqn8vsj7r0a5rvya76tey9jd2rdnca8lqh4kcuq", CKB::Address.generate(script, CKB::Address::HRP_TESTNET)
  end

  def test_full_payload_generate
    script = {
      code_hash: "0x1892ea40d82b53c678ff88312450bbb17e164d7a3e0a90941aa58839f56f8df2",
      args:      "0x36c329ed630d6ce750712a477543672adab57f4c",
      hash_type: "type"
    }
    assert_equal "ckb1qsvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlydkr98kkxrtvuag8z2j8w4pkw2k6k4l5czfy37k", CKB::Address.generate(script)
    assert_equal "ckt1qsvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlydkr98kkxrtvuag8z2j8w4pkw2k6k4l5c02auef", CKB::Address.generate(script, CKB::Address::HRP_TESTNET)

    script = {
      code_hash: "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176",
      args:      "0x36c329ed630d6ce750712a477543672adab57f4c",
      hash_type: "data"
    }
    assert_equal "ckb1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvdkr98kkxrtvuag8z2j8w4pkw2k6k4l5c0nw668", CKB::Address.generate(script)
    assert_equal "ckt1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvdkr98kkxrtvuag8z2j8w4pkw2k6k4l5czshhac", CKB::Address.generate(script, CKB::Address::HRP_TESTNET)
  end

  def test_short_address_parse
    script = CKB::Types::Script.new(
      code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
      args:      "0x36c329ed630d6ce750712a477543672adab57f4c",
      hash_type: "type"
    )
    address = "ckb1qyqrdsefa43s6m882pcj53m4gdnj4k440axqdt9rtd"
    parsed_script, payload_type, hrp = CKB::Address.parse(address)
    assert_equal parsed_script, script
    assert_equal CKB::Address::PAYLOAD_TYPE_SHORT, payload_type
    assert_equal :ckb, hrp
    address = "ckt1qyqrdsefa43s6m882pcj53m4gdnj4k440axqswmu83"
    parsed_script, payload_type, hrp = CKB::Address.parse(address)
    assert_equal parsed_script, script
    assert_equal CKB::Address::PAYLOAD_TYPE_SHORT, payload_type
    assert_equal :ckt, hrp

    script = CKB::Types::Script.new(
      code_hash: "0x5c5069eb0857efc65e1bca0c07df34c31663b3622fd3876c876320fc9634e2a8",
      args:      "0xf04cec84bc37f683613bed2f242c9aa1b678e9fe",
      hash_type: "type"
    )
    address = "ckb1qyqlqn8vsj7r0a5rvya76tey9jd2rdnca8lq2sg8su"
    parsed_script, payload_type, hrp = CKB::Address.parse(address)
    assert_equal parsed_script, script
    assert_equal CKB::Address::PAYLOAD_TYPE_SHORT, payload_type
    assert_equal :ckb, hrp
    address = "ckt1qyqlqn8vsj7r0a5rvya76tey9jd2rdnca8lqh4kcuq"
    parsed_script, payload_type, hrp = CKB::Address.parse(address)
    assert_equal parsed_script, script
    assert_equal CKB::Address::PAYLOAD_TYPE_SHORT, payload_type
    assert_equal :ckt, hrp
  end

  def test_full_address_parse
    script = CKB::Types::Script.new(
      code_hash: "0x1892ea40d82b53c678ff88312450bbb17e164d7a3e0a90941aa58839f56f8df2",
      args:      "0x36c329ed630d6ce750712a477543672adab57f4c",
      hash_type: "type"
    )
    address = "ckb1qsvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlydkr98kkxrtvuag8z2j8w4pkw2k6k4l5czfy37k"
    parsed_script, payload_type, hrp = CKB::Address.parse(address)
    assert_equal parsed_script, script
    assert_equal CKB::Address::PAYLOAD_TYPE_FULL, payload_type
    assert_equal :ckb, hrp
    address = "ckt1qsvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlydkr98kkxrtvuag8z2j8w4pkw2k6k4l5c02auef"
    parsed_script, payload_type, hrp = CKB::Address.parse(address)
    assert_equal parsed_script, script
    assert_equal CKB::Address::PAYLOAD_TYPE_FULL, payload_type
    assert_equal :ckt, hrp

    script = CKB::Types::Script.new(
      code_hash: "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176",
      args:      "0x36c329ed630d6ce750712a477543672adab57f4c",
      hash_type: "data"
    )
    address = "ckb1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvdkr98kkxrtvuag8z2j8w4pkw2k6k4l5c0nw668"
    parsed_script, payload_type, hrp = CKB::Address.parse(address)
    assert_equal parsed_script, script
    assert_equal CKB::Address::PAYLOAD_TYPE_FULL, payload_type
    assert_equal :ckb, hrp
    address = "ckt1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvdkr98kkxrtvuag8z2j8w4pkw2k6k4l5czshhac"
    parsed_script, payload_type, hrp = CKB::Address.parse(address)
    assert_equal parsed_script, script
    assert_equal CKB::Address::PAYLOAD_TYPE_FULL, payload_type
    assert_equal :ckt, hrp
  end

  def test_parse_error
    address = "ckn1qyqrdsefa43s6m882pcj53m4gdnj4k440axqswmu83"
    error = assert_raises(CKB::Address::ParseError) {CKB::Address.parse(address)}
    assert_equal "invalid hrp", error.message

    address = "ckt1qwn9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvdkr98kkxrtvuag8z2j8w4pkw2k6k4l5ctv25r2"
    error = assert_raises(CKB::Address::ParseError) {CKB::Address.parse(address)}
    assert_equal "invalid hash_type", error.message

    address = "ckt1qyzndsefa43s6m882pcj53m4gdnj4k440axqcth0hp"
    error = assert_raises(CKB::Address::ParseError) {CKB::Address.parse(address)}
    assert_equal "invalid code_hash_index", error.message

    address = "ckt1qyqrdsefa43s6m882pcj53m4gdnj4k440axqqm65l9j"
    error = assert_raises(CKB::Address::ParseError) {CKB::Address.parse(address)}
    assert_equal "invalid payload size", error.message
  end

  def test_empty_args_parse_and_as_json
    address = "ckt1qgqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqparrr6"
    parsed_script, _payload_type, _hrp = CKB::Address.parse(address)
    assert_equal("0x", parsed_script.as_json["args"])
  end
end
