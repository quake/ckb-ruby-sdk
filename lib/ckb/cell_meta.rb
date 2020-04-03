require "secp256k1"

module CKB
  class CellMeta
    attr_accessor :out_point, :output, :output_data_len, :cellbase
    attr_writer :output_data

    def initialize(out_point, output, output_data_len, cellbase)
      self.out_point = out_point
      self.output = output
      self.output_data_len = output_data_len
      self.cellbase = cellbase
    end

    def output_data
      @output_data ||= CKB::Config.instance.rpc.get_live_cell(self.out_point.as_json, true)[:cell][:data][:content].from_hex.bytes
    end
  end
end
