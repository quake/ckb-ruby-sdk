module CKB::Collector
  def self.default_scanner(lock_hashes)
    rpc = CKB::Config.instance.rpc
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

  def self.default_indexer(lock_hashes)
    rpc = CKB::Config.instance.rpc
    lock_hash_index, page, cell_metas_index, cell_metas = 0, 0, 0, []
    Enumerator.new do |result|
      while cell_metas_index < cell_metas.size || lock_hash_index < lock_hashes.size
        if cell_metas_index < cell_metas.size
          result << cell_metas[cell_metas_index]
          cell_metas_index += 1
        else
          cell_metas_index = 0
          cell_metas = rpc.get_live_cells_by_lock_hash(lock_hashes[lock_hash_index], page, 50).map do |h|
            CKB::CellMeta.new(CKB::Types::OutPoint.new(tx_hash: h[:created_by][:tx_hash], index: h[:created_by][:index]), CKB::Types::Output.new(h[:cell_output]))
          end
          page += 1
          if cell_metas.empty?
            page = 0
            lock_hash_index += 1
          end
        end
      end
    end
  end
end
