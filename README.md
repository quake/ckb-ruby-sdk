# ckb-ruby-sdk

Ruby SDK for CKB

The ckb-ruby-sdk is still under development and NOT production ready. You should get familiar with CKB transaction structure and RPC before using it.

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
rpc = CKB::RPC.new

# using RPC `get_tip_header`, it will return a Hash
rpc.get_tip_header
```

Send capacity

```ruby
# create api first
api = CKB::API.new
# create wallet object
wallet = CKB::Wallet.new(rpc)
# generate transaction
tx = wallet.gen_tx(
    "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37",
    "ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4",
    100_0000_0000,
    "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc".from_hex
)
# send transaction
rpc.send_transaction(tx.as_json)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Changelog

See [CHANGELOG](CHANGELOG.md) for more information.
