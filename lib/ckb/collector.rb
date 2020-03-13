module CKB::Collector
  def self.default_scanner(lock_hashes, store_file = nil)
    rpc = CKB::Config.instance.rpc
    tip_number = rpc.get_tip_block_number.to_i(16)
    store = DefaultScannerStore.new(lock_hashes, store_file)
    from, lock_hash_index, cell_metas_index, cell_metas = store.min_from, 0, 0, []
    Enumerator.new do |result|
      while cell_metas_index < cell_metas.size || from <= tip_number
        if cell_metas_index < cell_metas.size
          result << cell_metas[cell_metas_index]
          cell_metas_index += 1
        else
          cell_metas_index = 0
          lock_hash = lock_hashes[lock_hash_index]
          if store.skip_scan_util(lock_hash) < from
            cell_metas = []
          else
            cell_metas = rpc.get_cells_by_lock_hash(lock_hash, from, from + 100).map do |h|
              CKB::CellMeta.new(CKB::Types::OutPoint.new(h[:out_point]), CKB::Types::Output.new(h))
            end
            if cell_metas.empty?
              store.mark_if_necessary(lock_hash, from + 100, tip_number)
            else
              store.stop_mark(lock_hash)
            end
          end
          lock_hash_index += 1
          if lock_hash_index >= lock_hashes.size
            lock_hash_index = 0
            from += 100
          end
        end
      end
    end
  end

  # a store which persists scanned empty block height in file and avoids scanning from 0
  class DefaultScannerStore
    attr_accessor :store_file, :lock_hashes, :none_empty_lock_hashes

    def initialize(lock_hashes, store_file)
      self.lock_hashes = lock_hashes
      self.store_file = store_file || File.join(Dir.pwd, '.ckb_collector_default_scanner_store')
      self.none_empty_lock_hashes = Set.new
    end

    def min_from
      self.store.map{|k, v| lock_hashes.include?(k) ? v : nil}.compact.min.to_i
    end

    def store
      @store ||= File.exist?(store_file) ? JSON::parse(File.read(store_file)) : {}
    end

    def mark_if_necessary(lock_hash, from, tip_number)
      unless self.none_empty_lock_hashes.include?(lock_hash) || from > tip_number
        self.store[lock_hash] = from
        File.write(self.store_file, self.store.to_json)
      end
    end

    def skip_scan_util(lock_hash)
      self.store[lock_hash].to_i
    end

    def stop_mark(lock_hash)
      self.none_empty_lock_hashes << lock_hash
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
