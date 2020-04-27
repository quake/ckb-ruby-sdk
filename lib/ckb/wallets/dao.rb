module CKB::Wallets
  class Dao < Simple
    def advance_build(addresses_and_outputs_info, contexts = [])
      addresses_and_outputs_info.each do |address, output_info|
        output_info[:type] = CKB::Types::Script.dao_script
        output_info[:data] = CKB::Types::Bytes.new(Array.new(8, 0))
      end
      super(addresses_and_outputs_info, contexts)
    end


    def build_withdrawing(out_points, contexts = [])
      rpc = CKB::Config.instance.rpc
      inputs, outputs, outputs_data = [], [], []

      out_points.each do |out_point|
        inputs << CKB::Types::Input.new(since: 0, previous_output: out_point)
        outputs << rpc.get_live_cell(out_point.as_json, false)[:cell][:output]
        outputs_data << CKB::Types::Bytes.new([])
      end

      outputs << CKB::Types::Output.new(capacity: 0, lock: self.input_scripts.first, type: nil)
      outputs_data << CKB::Types::Bytes.new([])

      tx_builder = CKB::TransactionBuilder.new({
        version: 0, cell_deps: [], header_deps: [], inputs: inputs,
        outputs: outputs, outputs_data: outputs_data, witnesses: []
      })
      tx_builder.generate(self.collector, Hash[self.input_scripts.zip(contexts)])
      tx_builder
    end

    def withdraw(out_points)

    end
  end
end