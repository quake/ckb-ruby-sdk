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
    # @param context      [String | Array] private key string in raw format or multisig context
    def build(from_address, to_address, capacity, context = nil)
      # use from_address as change_address and set its capacity to 0
      advance_build [from_address], [to_address, from_address], [capacity, 0], [context]
    end

    def sign(tx_builder, from_address, context)
      advance_sign tx_builder, [from_address], [context]
    end

    def advance_build(from_addresses, to_addresses, capacities, contexts)
      input_scripts = from_addresses.map do |address|
        CKB::Address.parse(address).first
      end

      outputs = to_addresses.map.with_index do |address, i|
        script = CKB::Address.parse(address).first
        CKB::Types::Output.new capacity: capacities[i], lock: script, type: nil
      end
      outputs_data = Array.new(outputs.size, CKB::Types::Bytes.new([]))

      tx_builder = CKB::TransactionBuilder.new({
        version: 0, cell_deps: [], header_deps: [], inputs: [],
        outputs: outputs, outputs_data: outputs_data, witnesses: []
      }, self.rpc)
      collector = if self.collector_type == :default_indexer
        CKB::Collector.default_indexer(self.rpc, input_scripts.map{|script| script.compute_hash.to_hex})
      else
        CKB::Collector.default_scanner(self.rpc, input_scripts.map{|script| script.compute_hash.to_hex})
      end
      tx_builder.generate(collector, Hash[input_scripts.zip(contexts)])
      tx_builder
    end

    def advance_sign(tx_builder, from_addresses, contexts)
      input_scripts = from_addresses.map do |address|
        CKB::Address.parse(address).first
      end

      tx_builder.sign(Hash[input_scripts.zip(contexts)])
      tx_builder.transaction
    end
  end
end
