module CKB
  class Wallet
    attr_accessor :input_scripts, :collector

    def initialize(from_addresses, collector_type = :default_scanner)
      self.input_scripts = (from_addresses.is_a?(Array) ? from_addresses : [from_addresses]).map do |address|
        CKB::Address.parse(address).first
      end
      collector = if collector_type == :default_indexer
        CKB::Collector.default_indexer(self.input_scripts.map{|script| script.compute_hash.to_hex})
      else
        CKB::Collector.default_scanner(self.input_scripts.map{|script| script.compute_hash.to_hex})
      end
      self.collector = CKB::Wallet.collector_filter(collector)
    end

    # @param to_address   [String]
    # @param capacity     [Integer] unit shannon
    def build(to_address, capacity, output_info = {})
      advance_build(
        {
          to_address => {capacity: capacity, type: output_info[:type], data: output_info[:data] || []}
        },
        [output_info[:context]]
      )
    end

    def sign(tx_builder, context)
      advance_sign tx_builder, [context]
    end

    def advance_build(addresses_and_outputs_info, contexts = [])
      outputs, outputs_data = [], []

      addresses_and_outputs_info.each do |address, output_info|
        script = CKB::Address.parse(address).first
        outputs << CKB::Types::Output.new(capacity: output_info[:capacity], lock: script, type: output_info[:type])
        outputs_data << CKB::Types::Bytes.new(output_info[:data] || [])
      end

      # setup change output if necessary: use first input script as change output lock
      if outputs.all? {|output| output.capacity > 0}
        outputs << CKB::Types::Output.new(capacity: 0, lock: self.input_scripts.first, type: nil)
        outputs_data << CKB::Types::Bytes.new([])
      end

      tx_builder = CKB::TransactionBuilder.new({
        version: 0, cell_deps: [], header_deps: [], inputs: [],
        outputs: outputs, outputs_data: outputs_data, witnesses: []
      })
      tx_builder.generate(collector, Hash[self.input_scripts.zip(contexts)])
      tx_builder
    end

    def advance_sign(tx_builder, contexts)
      tx_builder.sign(Hash[self.input_scripts.zip(contexts)])
      tx_builder.transaction
    end

    def self.collector_filter(collector)
      Enumerator.new do |result|
        loop do
          begin
            cell_meta = collector.next
            if cell_meta.output_data_len == 0 && cell_meta.output.type == nil
              result << cell_meta
            end
          rescue StopIteration
            break
          end
        end
      end
    end
  end
end
