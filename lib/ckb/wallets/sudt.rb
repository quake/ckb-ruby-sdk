module CKB::Wallets
  class Sudt < Simple
    DATA_PLACE_HOLDER = CKB::Types::Bytes.new(Array.new(16, 0))

    attr_accessor :sudt, :is_issuer

    def initialize(from_addresses, sudt, collector_type = :default_scanner)
      super(from_addresses, collector_type)
      self.sudt = sudt
      self.is_issuer = self.input_scripts.size == 1 && self.input_scripts.first.compute_hash.to_hex == self.sudt.args.to_hex
    end

    # @param to_address   [String]
    # @param udt_capacity [Integer]
    def build(to_address, sudt_amount, output_info = {})
      data = [sudt_amount].u64_serialize + [sudt_amount >> 64].u64_serialize
      lock = CKB::Address.parse(to_address).first
      output = CKB::Types::Output.new(lock: lock, type: self.sudt)
      capacity = output.occupied_capacity(data)

      advance_build(
        {
          to_address => {capacity: capacity, type: self.sudt, data: data}
        },
        [output_info[:context]]
      )
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
        if self.is_issuer
          outputs << CKB::Types::Output.new(capacity: 0, lock: self.input_scripts.first, type: nil)
          outputs_data << CKB::Types::Bytes.new([])
        else
          output = CKB::Types::Output.new(lock: self.input_scripts.first, type: self.sudt)
          output.capacity = output.occupied_capacity(DATA_PLACE_HOLDER)
          outputs << output
          outputs_data << DATA_PLACE_HOLDER.dup

          outputs << CKB::Types::Output.new(capacity: 0, lock: self.input_scripts.first, type: nil)
          outputs_data << CKB::Types::Bytes.new([])
        end
      end

      tx_builder = SudtTransactionBuilder.new({
        version: 0, cell_deps: [], header_deps: [], inputs: [],
        outputs: outputs, outputs_data: outputs_data, witnesses: []
      })
      tx_builder.is_issuer = self.is_issuer
      tx_builder.generate(self.collector, Hash[self.input_scripts.zip(contexts)])
      tx_builder
    end

    def collector
      collector = if self.collector_type == :default_indexer
        CKB::Collector.default_indexer(self.input_scripts.map{|script| script.compute_hash.to_hex})
      else
        CKB::Collector.default_scanner(self.input_scripts.map{|script| script.compute_hash.to_hex})
      end

      Enumerator.new do |result|
        loop do
          begin
            cell_meta = collector.next
            if self.is_issuer ? (cell_meta.output_data_len == 0 && cell_meta.output.type == nil) : (cell_meta.output.type == nil || cell_meta.output.type == self.sudt)
              result << cell_meta
            end
          rescue StopIteration
            break
          end
        end
      end
    end
  end

  class SudtTransactionBuilder < CKB::TransactionBuilder
    attr_accessor :is_issuer

    def enough_capacity?(change_capacity_output_index, fee_rate)
      if super(change_capacity_output_index, fee_rate)
        if self.is_issuer
          true
        else
          inputs_sudt_amount = cell_metas.select{|cm| cm.output.type != nil}.map{|cm| sudt_amount(cm.output_data)}.sum
          outputs_sudt_amount = self.transaction.outputs_data.map{|output_data| sudt_amount(output_data)}.sum
          change_sudt_amount = inputs_sudt_amount - outputs_sudt_amount
          if change_sudt_amount > 0
            data = [change_sudt_amount].u64_serialize + [change_sudt_amount >> 64].u64_serialize
            change_sudt_output_index = self.transaction.outputs_data.find_index(Sudt::DATA_PLACE_HOLDER)
            self.transaction.outputs_data[change_sudt_output_index] = CKB::Types::Bytes.new(data)
            true
          elsif change_sudt_amount == 0
            change_sudt_output_index = self.transaction.outputs_data.find_index(Sudt::DATA_PLACE_HOLDER)
            self.transaction.outputs[change_capacity_output_index].capacity += self.transaction.outputs[change_sudt_output_index].capacity
            self.transaction.outputs.delete_at(change_sudt_output_index)
            self.transaction.outputs_data.delete_at(change_sudt_output_index)
            true
          end
        end
      end
    end

    def sudt_amount(output_data)
      output_data.each_with_index.inject(0) {|r, (a, i)| r + a * 256 ** i}
    end
  end
end
