require 'csv'

class LoaderWorker
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: 2, backtrace: true

  def perform(file_import_id, offset, limit)
    file_import = FileImport.find_by(id: file_import_id)
    return unless file_import

    file = file_import.file.download
    csv = CSV.parse(file, headers: true, header_converters: :symbol)

    rows = csv.to_a[offset, limit] || []
    rows = rows.select { |row| row.is_a?(CSV::Row) }

    array_of_args = rows.map.with_index(offset + 1) do |row, row_number|
      row_hash = row.to_h.transform_keys(&:to_s)
      row_hash.merge!(
        "file_import_id" => file_import.id,
        "row_number" => row_number
      )
      [row_hash] # Arguments for ProductRowWorker
    end

    # ✅ Uses perform_bulk for optimized Sidekiq enqueueing
    ProductRowWorker.perform_bulk(array_of_args) if array_of_args.any?

    # ✅ Manually track job completion
    check_and_finalize_import(file_import_id)
  end

  private

  def check_and_finalize_import(file_import_id)
    remaining_jobs_key = "file_import:#{file_import_id}:remaining_jobs"

    remaining = Sidekiq.redis { |conn| conn.decr(remaining_jobs_key) }

    return unless remaining.to_i <= 0

    file_import = FileImport.find_by(id: file_import_id)
    return unless file_import

    if FileImportLog.where(file_import_id: file_import.id, status: "failed").exists?
      file_import.update(status: "failed")
      FileImportMailer.import_failed(file_import).deliver_later
    else
      file_import.update(status: "completed")
      FileImportMailer.import_success(file_import).deliver_later
    end
  end
end