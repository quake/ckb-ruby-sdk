require "secp256k1"

module CKB
  class Wallet
    attr_accessor :rpc, :collector_type

    def initialize(rpc, collector_type = :default_scanner)
      self.rpc = rpc
      self.collector_type = collector_type
    end

    # @param from_address [String]
    # @param to_address   [String]
    # @param capacity     [Integer] unit shannon
    # @param private_key  [String] raw format
    def gen_tx(from_address, to_address, capacity, private_key)
      # use from_address as change_address and set its capacity to 0
      advance_gen_tx [from_address], [to_address, from_address], [capacity, 0], [private_key]
    end

    def advance_gen_tx(from_addresses, to_addresses, capacities, private_keys)
      input_scripts = from_addresses.map do |address|
        CKB::Address.parse(address).first
      end

      outputs = to_addresses.map.with_index do |address, i|
        script = CKB::Address.parse(address).first
        CKB::Types::Output.new capacity: capacities[i], lock: script, type: nil
      end
      outputs_data = Array.new(outputs.size, CKB::Types::Bytes.new([]))

      builder = CKB::TransactionBuilder.new({
        version: 0, cell_deps: [], header_deps: [], inputs: [],
        outputs: outputs, outputs_data: outputs_data, witnesses: []
      }, self.rpc)
      collector = if self.collector_type == :default_indexer
        CKB::Collector.default_indexer(self.rpc, input_scripts.map{|script| script.compute_hash.to_hex})
      else
        CKB::Collector.default_scanner(self.rpc, input_scripts.map{|script| script.compute_hash.to_hex})
      end
      builder.generate(collector)
      builder.sign(Hash[input_scripts.zip(private_keys.map{|pk| Secp256k1::PrivateKey.new(privkey: pk)})])
      builder.transaction
    end
  end
end
