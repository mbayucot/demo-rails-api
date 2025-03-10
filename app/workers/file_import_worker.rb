require 'csv'

class FileImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform(file_import_id)
    file_import = FileImport.find_by(id: file_import_id)
    return unless file_import&.in_progress?

    begin
      validate_and_process_file(file_import)
      file_import.mark_completed! if file_import.all_rows_processed?
    rescue => e
      file_import.mark_failed! if file_import.may_mark_failed?
      Rails.logger.error("FileImportWorker failed: #{e.message}")
    end
  end

  private

  def validate_and_process_file(file_import)
    file_path = ActiveStorage::Blob.service.path_for(file_import.file.key)
    csv_data = CSV.read(file_path, headers: true)

    # ✅ Step 1: Validate CSV Headers
    csv_validation = CsvValidator.call(csv_data.headers)
    unless csv_validation[:success]
      file_import.mark_failed!
      Rails.logger.error("CSV Header Validation Failed: #{csv_validation[:error]}")
      return
    end

    # ✅ Step 2: Process Each Row
    #csv_data.each.with_index(1) do |row, index|
    #  process_row(file_import, row.to_h, index)
    #end
  end

  def process_row(file_import, row, index)
    result = ProductImportService.process(row)

    if result[:success]
      file_import.increment!(:processed_rows)
    else
      Mongo::FileImportLog.create!(
        file_import_id: file_import.id,
        row_number: index,
        status: "failed",
        message: "Error: #{result[:error]}"
      )
    end
  end
end