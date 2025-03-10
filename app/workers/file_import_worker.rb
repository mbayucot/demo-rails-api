require 'csv' # ✅ Fix: Ensure CSV module is available

class FileImportWorker
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: 3, backtrace: true

  BATCH_SIZE = 1000 # Each loader processes 1000 rows

  def perform(file_import_id)
    file_import = FileImport.find_by(id: file_import_id)
    return unless file_import

    file_import.update(status: "in_progress")

    file = file_import.file.download
    csv = CSV.parse(file, headers: true, header_converters: :symbol) # ✅ Now CSV is available

    batch = Sidekiq::Batch.new
    batch.on(:complete, FileImportBatchCallback, "file_import_id" => file_import_id)

    batch.jobs do
      total_rows = csv.length
      (0..(total_rows / BATCH_SIZE)).each do |idx|
        LoaderWorker.perform_async(file_import_id, idx * BATCH_SIZE, BATCH_SIZE)
      end
    end
  end
end