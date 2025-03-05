class ImportProductsService
  include Dry::Transaction

  step :parse_csv
  step :process_rows
  step :finalize_import
  step :send_notification

  def parse_csv(input)
    store_import_log = input[:store_import_log]

    retryable(tries: 3, sleep: lambda { |n| 2**n }) do
      store_import_log.start_processing!

      store_import_log.update!(total_records: 0, processed_records: 0, error_records: 0)

      file = URI.open(store_import_log.file_url)

      # Process in batches instead of loading the entire file
      CSV.foreach(file, headers: true).each_slice(1000) do |batch|
        batch.each do |row|
          row_data = row.to_h.merge(store_id: store_import_log.store_id)
          ImportProductRowJob.perform_later(store_import_log.id, row_data)
        end
      end
    end

    Success(input)
  rescue => e
    Rails.logger.error("CSV Parsing Failed: #{e.message}")
    store_import_log.fail!
    Failure("CSV Parsing failed after 3 retries: #{e.message}")
  end

  def process_rows(input)
    store_import_log = input[:store_import_log]

    until store_import_log.store_import_rows.where(status: :pending).count.zero?
      sleep(5) # Polling interval
    end

    Success(input)
  end

  def finalize_import(input)
    store_import_log = input[:store_import_log]
    store_import_log.complete!
    Success(input)
  end

  def send_notification(input)
    store_import_log = input[:store_import_log]
    ImportNotificationJob.perform_later(input[:user_id], store_import_log.id)
    Success("Import completed, email notification sent")
  end
end