require 'bech32'

module CKB::Address
  HRP_MAINNET = :ckb
  HRP_TESTNET = :ckt

  PAYLOAD_TYPE_SHORT = :short
  PAYLOAD_TYPE_FULL = :full

  MAX_PAYLOAD_SIZE = 2**31 - 1

  # https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md
  def self.generate(script, network = CKB.network)
    script = CKB::Types::Script.new(script) if script.is_a?(Hash)
    payload = if script.hash_type == CKB::Types::Script::HASH_TYPE_TYPE && script.args.size == 20
      if script.code_hash == CKB::Types::Script::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH
        [1, 0] + script.args
      elsif script.code_hash == CKB::Types::Script::SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH
        [1, 1] + script.args
      end
    end || [script.hash_type == CKB::Types::Script::HASH_TYPE_DATA ? 2 : 4] + script.code_hash + script.args

    Bech32.encode((network == CKB::MAINNET ? HRP_MAINNET : HRP_TESTNET).to_s, self.convert_bits(payload, 8, 5))
  end

  def self.parse(address)
    hrp, data = Bech32.decode(address, MAX_PAYLOAD_SIZE)
    raise ParseError, "invalid hrp" if hrp != HRP_MAINNET.to_s && hrp != HRP_TESTNET.to_s
    payload = self.convert_bits(data, 5, 8, false)
    code_hash, args, hash_type, payload_type = if payload[0] == 1
      raise ParseError, "invalid payload size" if payload.size != 22
      if payload[1] == 0
        [CKB::Types::Script::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, payload[2..-1], CKB::Types::Script::HASH_TYPE_TYPE, PAYLOAD_TYPE_SHORT]
      elsif payload[1] == 1
        [CKB::Types::Script::SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH, payload[2..-1], CKB::Types::Script::HASH_TYPE_TYPE, PAYLOAD_TYPE_SHORT]
      else
        raise ParseError, "invalid code_hash_index"
      end
    else
      raise ParseError, "invalid payload size" if payload.size < 33
      if payload[0] == 2
        [payload[1..32], payload[33..-1], CKB::Types::Script::HASH_TYPE_DATA, PAYLOAD_TYPE_FULL]
      elsif payload[0] == 4
        [payload[1..32], payload[33..-1], CKB::Types::Script::HASH_TYPE_TYPE, PAYLOAD_TYPE_FULL]
      else
        raise ParseError, "invalid hash_type"
      end
    end
    [CKB::Types::Script.new(code_hash: code_hash, args: args, hash_type: hash_type), payload_type, hrp.to_sym]
  end

  class ParseError < RuntimeError; end

  private

  # copy from: https://github.com/azuchi/bech32rb/blob/ea80825a611319f38d5898bb770ae2e05051b71a/lib/bech32/segwit_addr.rb#L48-L69
  def self.convert_bits(data, from, to, padding = true)
    acc = 0
    bits = 0
    ret = []
    maxv = (1 << to) - 1
    max_acc = (1 << (from + to - 1)) - 1
    data.each do |v|
      return nil if v < 0 || (v >> from) != 0

      acc = ((acc << from) | v) & max_acc
      bits += from
      while bits >= to
        bits -= to
        ret << ((acc >> bits) & maxv)
      end
    end
    if padding
      ret << ((acc << (to - bits)) & maxv) unless bits == 0
    elsif bits >= from || ((acc << (to - bits)) & maxv) != 0
      return nil
    end
    ret
  end
end
