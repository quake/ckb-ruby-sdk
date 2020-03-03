$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ckb"

require "minitest/autorun"

def sanitize_hash(h)
  {}.tap do |result|
    h.sort.each do |k,v|
      next if v == "0x" || v == [] || v == nil
      result[k.to_s] = if v.is_a?(Hash)
        sanitize_hash(v)
      elsif v.is_a?(Array) && v.first.is_a?(Hash)
        v.map{|a| sanitize_hash(a)}
      else
        v
      end
    end
  end
end
