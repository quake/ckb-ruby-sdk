require "test_helper"

class ScriptTest < Minitest::Test
  def test_compute_hash
    script = {
      code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
      args:      "0x36c329ed630d6ce750712a477543672adab57f4c",
      hash_type: "type"
    }

    # hash is copied from rpc._compute_script_hash(script)
    assert_equal "0x1f2615a8dde4e28ca736ff763c2078aff990043f4cbf09eb4b3a58a140a0862d", CKB::Types::Script.new(script).compute_hash.to_hex
  end

  def test_occupied_capacity
    script = {
      code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
      args:      "0x36c329ed630d6ce750712a477543672adab57f4c",
      hash_type: "type"
    }

    assert_equal 53, CKB::Types::Script.new(script).occupied_capacity
  end
end
