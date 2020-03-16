require "secp256k1"

module CKB
  class CellMeta
    attr_accessor :out_point, :output

    def initialize(out_point, output)
      self.out_point = out_point
      self.output = output
    end

    SIGNATURE_PLACE_HOLDER = Array.new(65, 0)

    class DefaultSighash
      def self.generate(cell_meta, tx_builder, context)
        tx_builder.transaction.inputs << CKB::Types::Input.new(since: 0, previous_output: cell_meta.out_point)
        cell_dep = CKB::Types::CellDep.standard_secp256k1_blake160_sighash_all
        tx_builder.transaction.cell_deps << cell_dep unless tx_builder.transaction.cell_deps.include?(cell_dep)
        witness = if tx_builder.cell_metas.any?{|cm| cm.output.lock == cell_meta.output.lock}
          []
        else
          # build witness with signature placeholder
          CKB::Types::WitnessArgs.new(lock: CKB::Types::Bytes.new(SIGNATURE_PLACE_HOLDER)).serialize
        end
        tx_builder.transaction.witnesses << CKB::Types::Bytes.new(witness)
        tx_builder.cell_metas << cell_meta
      end

      # @param context      [String] private key string in raw format
      def self.sign(cell_meta, tx_builder, context)
        cell_meta_index = tx_builder.cell_metas.find_index{|cm| cm.out_point == cell_meta.out_point}
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
      end
    end

    class DefaultMultisig
      # @param context      [Array] multisig script, format: [S, R, M, N, blake160(pubkey1), blake160(pubkey2), ...]
      def self.generate(cell_meta, tx_builder, context)
        tx_builder.transaction.inputs << CKB::Types::Input.new(since: 0, previous_output: cell_meta.out_point)
        cell_dep = CKB::Types::CellDep.standard_secp256k1_blake160_multisig_all
        tx_builder.transaction.cell_deps << cell_dep unless tx_builder.transaction.cell_deps.include?(cell_dep)
        witness = if tx_builder.cell_metas.any?{|cm| cm.output.lock == cell_meta.output.lock}
          []
        else
          # build witness with signature placeholder
          bytes =
            context[0, 4] +
            context[4..-1].map(&:bytes).flatten +
            (SIGNATURE_PLACE_HOLDER * context[2])
          CKB::Types::WitnessArgs.new(lock: CKB::Types::Bytes.new(bytes)).serialize
        end
        tx_builder.transaction.witnesses << CKB::Types::Bytes.new(witness)
        tx_builder.cell_metas << cell_meta
      end

      # @param context      [Array] private key string in raw format
      def self.sign(cell_meta, tx_builder, context)
        cell_meta_index = tx_builder.cell_metas.find_index{|cm| cm.out_point == cell_meta.out_point}
        lock = tx_builder.cell_metas[cell_meta_index].output.lock
        grouped_indexes = tx_builder.cell_metas.map.with_index{|cm, index| index if cm.output.lock == lock }.compact
        if cell_meta_index == grouped_indexes.first
          transaction = tx_builder.transaction
          witness = tx_builder.transaction.witnesses[cell_meta_index]
          # 22 / 23 is the position of multisig script‘s N and M in serialized witness, it is calculated by hand
          # TODO: refactor to use molcule deserialize
          required_signatures = witness[22]
          total_public_keys = witness[23]
          signature_offset = 24 + 20 * total_public_keys

          blake2b = CKB::Blake2b.new
          blake2b << transaction.compute_hash
          grouped_indexes.each do |index|
            w = transaction.witnesses[index].dup
            # reset lock witness' signed signatures to placeholder
            if index == cell_meta_index
              w[signature_offset, 65 * required_signatures] = SIGNATURE_PLACE_HOLDER * required_signatures
            end
            blake2b << [w.size].u64_serialize
            blake2b << w
          end

          digest = blake2b.digest
          context.each do |key|
            private_key = Secp256k1::PrivateKey.new(privkey: key)
            signature, recid = private_key.ecdsa_recoverable_serialize(private_key.ecdsa_sign_recoverable(digest, raw: true))
            witness[signature_offset..-1].each_slice(65).with_index do |s, i|
              if s == SIGNATURE_PLACE_HOLDER
                witness[signature_offset + 65 * i, 65] = signature.bytes + [recid]
                break
              end
            end
          end
        end
      end
    end
  end
end
