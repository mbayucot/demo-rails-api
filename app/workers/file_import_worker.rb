require 'csv'

class FileImportWorker
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: 3, backtrace: true

  BATCH_SIZE = 1000

  def perform(file_import_id)
    file_import = FileImport.find_by(id: file_import_id)
    return unless file_import

    file_import.update(status: "in_progress")

    file = file_import.file.download
    csv = CSV.parse(file, headers: true, header_converters: :symbol)

    total_rows = csv.length
    return if total_rows.zero?

    # ✅ Instead of using Sidekiq::Batch, we manually track the job completion
    total_jobs = (total_rows / BATCH_SIZE.to_f).ceil
    remaining_jobs_key = "file_import:#{file_import_id}:remaining_jobs"

    # Initialize remaining jobs counter in Redis
    Sidekiq.redis { |conn| conn.set(remaining_jobs_key, total_jobs) }

    (0...total_jobs).each do |idx|
      LoaderWorker.perform_async(file_import_id, idx * BATCH_SIZE, BATCH_SIZE)
    end
  end
end