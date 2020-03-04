require "secp256k1"

module CKB
  class CellMeta
    attr_accessor :out_point, :output

    def initialize(out_point, output)
      self.out_point = out_point
      self.output = output
    end

    def generate(tx_builder, context)
      if self.output.lock.standard_secp256k1_blake160_sighash_all?
        tx_builder.transaction.inputs << CKB::Types::Input.new(since: 0, previous_output: self.out_point)
        cell_dep = CKB::Types::CellDep.standard_secp256k1_blake160_sighash_all(tx_builder.rpc.genesis_block)
        tx_builder.transaction.cell_deps << cell_dep unless tx_builder.transaction.cell_deps.include?(cell_dep)
        witness = if tx_builder.cell_metas.any?{|cm| cm.output.lock == self.output.lock}
          []
        else
          # build witness with signature placeholder
          CKB::Types::WitnessArgs.new(lock: CKB::Types::Bytes.new(Array.new(65, 0))).serialize
        end
        tx_builder.transaction.witnesses << CKB::Types::Bytes.new(witness)
        tx_builder.cell_metas << self
      elsif self.output.lock.standard_secp256k1_blake160_multisig_all?
        tx_builder.transaction.inputs << CKB::Types::Input.new(since: 0, previous_output: self.out_point)
        cell_dep = CKB::Types::CellDep.standard_secp256k1_blake160_multisig_all(tx_builder.rpc.genesis_block)
        tx_builder.transaction.cell_deps << cell_dep unless tx_builder.transaction.cell_deps.include?(cell_dep)
        witness = if tx_builder.cell_metas.any?{|cm| cm.output.lock == self.output.lock}
          []
        else
          # build witness with signature placeholder
          bytes =
            context[0, 4] +
            context[4..-1].map{|key| CKB::Blake2b.digest(Secp256k1::PrivateKey.new(privkey: key).pubkey.serialize).bytes.first(20)}.flatten +
            Array.new((context.size - 4) * 65, 0)
          CKB::Types::WitnessArgs.new(lock: CKB::Types::Bytes.new(bytes)).serialize
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
          private_key = Secp256k1::PrivateKey.new(privkey: context)
          signature, recid = private_key.ecdsa_recoverable_serialize(private_key.ecdsa_sign_recoverable(blake2b.digest, raw: true))
          tx_builder.transaction.witnesses[cell_meta_index][20, 65] = signature.bytes + [recid]
        end
      elsif self.output.lock.standard_secp256k1_blake160_multisig_all?
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
          digest = blake2b.digest
          total_public_keys = context[3]
          signature_offset = 24 + 20 * total_public_keys
          context[4..-1].each_with_index do |key, index|
            private_key = Secp256k1::PrivateKey.new(privkey: key)
            signature, recid = private_key.ecdsa_recoverable_serialize(private_key.ecdsa_sign_recoverable(blake2b.digest, raw: true))
            tx_builder.transaction.witnesses[cell_meta_index][signature_offset + 65 * index, 65] = signature.bytes + [recid]
          end
        end
      end
    end
  end
end
