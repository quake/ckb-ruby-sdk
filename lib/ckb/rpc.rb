require "net/http/persistent"
require "json"
require 'securerandom'
require "uri"

module CKB
  class RPC
    attr_reader :uri, :http

    def initialize(host)
      @uri = URI(host)
      @http = Net::HTTP::Persistent.new
    end

    # Allows to call RPC methods as if they were defined functions:
    # rpc.rpc_method_name(...)
    # @param method [Symbol] A RPC method name
    # @param args [Array] The arguments for the method are passed as parameters to the function
    def method_missing(method, *args)
      single_request(method, args)
    end

    def single_request(method, args)
      response = post(method: method, params: args, jsonrpc: '2.0', id: SecureRandom.uuid)
      parsed_response = parse_response(response)
      raise Error, parsed_response[:error] if parsed_response[:error]
      parsed_response[:result]
    end

    def genesis_block
      @genesis_block ||= get_block_by_number("0x0")
    end

    class Error < RuntimeError; end

    private
    def post(body)
      request = Net::HTTP::Post.new('/')
      # convert all number value to hex string, a bit hacky but works
      # `[42]` and `"abc":42` will be converted to `["0x2a"]` and `"abc":"0x2a"`
      request.body = body.to_json.gsub(/[:\[,]\K(\d+)/) { |s| '"0x%x"' % s }
      request['Content-Type'] = 'application/json'
      self.http.request(self.uri, request)
    end

    def parse_response(response)
      if response.code == '200'
        JSON.parse(response.body, symbolize_names: true)
      else
        error_messages = {body: response.body, code: response.code}
        raise Error, error_messages
      end
    end
  end
end
