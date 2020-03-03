module CKB::Collector
  def self.by_rpc(rpc, lock_hashes)
    tip_number = rpc.get_tip_block_number.to_i(16)
    lock_hash_index, from, cell_metas_index, cell_metas = 0, 0, 0, []
    Enumerator.new do |result|
      while cell_metas_index < cell_metas.size || lock_hash_index < lock_hashes.size
        if cell_metas_index < cell_metas.size
          result << cell_metas[cell_metas_index]
          cell_metas_index += 1
        else
          cell_metas_index = 0
          cell_metas = rpc.get_cells_by_lock_hash(lock_hashes[lock_hash_index], from, from + 100).map do |h|
            CKB::CellMeta.new(CKB::Types::OutPoint.new(h[:out_point]), CKB::Types::Output.new(h))
          end
          from += 100
          if from > tip_number
            from = 0
            lock_hash_index += 1
          end
        end
      end
    end
  end

  def self.by_rpc_indexer(rpc, lock_hashes)
    # TODO implement Enumerator by using indexer rpc
  end
end
