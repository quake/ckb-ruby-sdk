# ckb-ruby-sdk

Ruby SDK for CKB

The ckb-ruby-sdk is still under development. You should get familiar with CKB transaction structure and RPC before using it.

## Prerequisites

Require Ruby 2.4 and above.

### Ubuntu

```bash
sudo apt install libsodium-dev
```

This SDK depends on the [bitcoin-secp256k1](https://github.com/cryptape/ruby-bitcoin-secp256k1) gem. You need to install libsecp256k1 with `--enable-module-recovery` (on which bitcoin-secp256k1 depends) manually. Follow [this](https://github.com/cryptape/ruby-bitcoin-secp256k1#prerequisite) to do so.

### macOS

```bash
brew tap nervosnetwork/tap
brew install libsodium libsecp256k1
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ckb-ruby-sdk', github: 'quake/ckb-ruby-sdk'
```

And then execute:

    $ bundle install

If you just want to use it in a console:

```
git clone https://github.com/quake/ckb-ruby-sdk.git
cd ckb-ruby-sdk
bundle install
bundle exec bin/console
```

## Usage

RPC interface returns parsed `JSON` object

```ruby
rpc = CKB::Config.instance.rpc

# using RPC `get_tip_header`, it will return a Hash
rpc.get_tip_header
```

Send capacity

```ruby
# create wallet object
wallet = CKB::Wallets::Simple.new("ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
# build transaction
tx_builder = wallet.build("ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4", 100_0000_0000)
# sign
tx = wallet.sign(tx_builder, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc".from_hex)
# send transaction
CKB::Config.instance.rpc.send_transaction(tx.as_json)
```

Send capacity to multiple addresses

```ruby
tx_builder = wallet.advance_build(
    "ckt1qyqr8ljpvy6y7t0cp2m0prv2whvm05whjzeqaydfze" => {capacity: 1234_0000_0000},
    "ckt1qyq0myesdwxwntsra2m75xtp8k7q8nphjmksxyzz0c" => {capacity: 4321_0000_0000},
)
```

Collect inputs with multiple addresses

```ruby
wallet = CKB::Wallets::Simple.new(["ckt1qyqr8ljpvy6y7t0cp2m0prv2whvm05whjzeqaydfze", "ckt1qyq0myesdwxwntsra2m75xtp8k7q8nphjmksxyzz0c"])
tx_builder = wallet.build("ckt1qyqkqqppzt0svxzyedfe7jt0dhxhd9rvt2dskqrjem", 5000_0000_0000)
tx = wallet.sign(tx_builder, ["0x92116fee8735bd5d95f5f0e773a887f1a7d0b3d0c6007c8a66f844acffb9adc0".from_hex, "0x252948dddb55a54c93bf05c468acbaa6683c763c39132e71fd8ecb9fb6f88f5d".from_hex])
```

Deploy a contract binary or send capacity with data

```ruby
data = File.read("/your-path-to/binary").unpack("C*")
tx_builder = wallet.build("ckt1qgqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqparrr6", 1800_0000_0000, {data: data})
```

Deploy a contract binary with type id

```ruby
data = File.read("/your-path-to/binary").unpack("C*")
type_script = CKB::Types::Script.new(
    code_hash: CKB::Types::Script::TYPE_ID_HASH,
    hash_type: CKB::Types::Script::HASH_TYPE_TYPE
)
tx_builder = wallet.build("ckt1qgqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqparrr6", 1800_0000_0000, {data: data, type: type_script})
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Changelog

See [CHANGELOG](CHANGELOG.md) for more information.
