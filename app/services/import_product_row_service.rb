class ImportProductRowService
  include Dry::Transaction

  step :validate_row
  step :insert_product

  def validate_row(input)
    row_data = input[:row_data]
    store_import_log = input[:store_import_log]

    validation = ProductImportContract.new.call(row_data)

    row_log = store_import_log.store_import_rows.create!(row_data: row_data)

    if validation.success?
      row_log.validate_row!
      Success(input.merge(row_log: row_log))
    else
      row_log.errors << validation.errors.to_h.to_s
      row_log.invalid!
      increment_counter(:error_records, store_import_log) # Apply Lock on Counter Update
      Failure("Invalid row data: #{validation.errors.to_h}")
    end
  end

  def insert_product(input)
    row_log = input[:row_log]
    row_data = input[:row_data]
    store_import_log = input[:store_import_log]

    retryable(tries: 3, sleep: lambda { |n| 2**n }, on: [ActiveRecord::Deadlocked, ActiveRecord::RecordNotUnique]) do
      Product.transaction do
        Product.insert_all([row_data]) # Bulk insert
        row_log.process_row!
        increment_counter(:processed_records, store_import_log) # Apply Lock on Counter Update
      end
    end

    Success("Row processed successfully")
  rescue => e
    Rails.logger.error("Database insert failed: #{e.message}")
    Failure("Row failed after 3 retries: #{e.message}")
  end

  private

  def increment_counter(counter_name, store_import_log)
    StoreImportLog.transaction do
      store_import_log.lock!
      store_import_log.increment!(counter_name)
    end
  end
end