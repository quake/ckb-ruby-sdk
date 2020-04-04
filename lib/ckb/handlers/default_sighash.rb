module CKB
  module Handlers
    class DefaultSighash
      SIGNATURE_PLACE_HOLDER = Array.new(65, 0)

      def generate(cell_meta, tx_builder, context)
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
      def sign(cell_meta, tx_builder, context)
        lock = cell_meta.output.lock
        cell_meta_index = tx_builder.cell_metas.find_index{|cm| cm.out_point == cell_meta.out_point}
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
  end
end