module CKB
  class CellMeta
    attr_accessor :out_point, :output

    def initialize(out_point, output)
      self.out_point = out_point
      self.output = output
    end

    def generate(tx_builder)
      if self.output.lock.standard_secp256k1_blake160_sighash_all?
        tx_builder.transaction.inputs << CKB::Types::Input.new(since: 0, previous_output: self.out_point)
        cell_dep = CKB::Types::CellDep.standard_secp256k1_blake160_sighash_all(tx_builder.rpc.genesis_block)
        tx_builder.transaction.cell_deps << cell_dep unless tx_builder.transaction.cell_deps.include?(cell_dep)
        witness = if tx_builder.cell_metas.any?{|cm| cm.output.lock == self.output.lock}
          []
        else
          CKB::Types::WitnessArgs.new(lock: CKB::Types::Bytes.new(Array.new(65, 0))).serialize
        end
        tx_builder.transaction.witnesses << CKB::Types::Bytes.new(witness)
        tx_builder.cell_metas << self
      end
    end

    def sign(tx_builder, context)
      if self.output.lock.standard_secp256k1_blake160_sighash_all?
        cell_meta_index = tx_builder.cell_metas.find_index{|cm| cm.out_point == self.out_point}
        lock = tx_builder.cell_metas[cell_meta_index].output.lock
        grouped_indexes = tx_builder.cell_metas.map.with_index{|cm, index| index if cm.output.lock == lock }.compact
        if cell_meta_index == grouped_indexes.first
          transaction = tx_builder.transaction
          blake2b = CKB::Blake2b.new
          blake2b << transaction.compute_hash
          grouped_indexes.each do |index|
            witness = transaction.witnesses[index]
            blake2b << [witness.size].u64_serialize
            blake2b << witness
          end
          signature, recid = context.ecdsa_recoverable_serialize(context.ecdsa_sign_recoverable(blake2b.digest, raw: true))
          tx_builder.transaction.witnesses[cell_meta_index][20, 65] = signature.bytes + [recid]
        end
      end
    end
  end
end
