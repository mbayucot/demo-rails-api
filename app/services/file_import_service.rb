class FileImportService
  include Dry::Transaction

  step :fetch_file_import
  step :validate_csv
  step :process_rows
  step :mark_completed

  # Step 1: Fetch the FileImport record
  def fetch_file_import(file_import_id)
    file_import = FileImport.find_by(id: file_import_id)
    return Failure("FileImport #{file_import_id} not found") unless file_import

    Success(file_import)
  end

  # Step 2: Validate CSV headers before processing
  def validate_csv(file_import)
    file = file_import.file.download
    csv = CSV.parse(file, headers: true, header_converters: :symbol)

    validation = CsvContract.new.call(headers: csv.headers.map(&:to_s))
    return Failure("Invalid CSV headers: #{validation.errors.to_h}") unless validation.success?

    Success(file_import: file_import, csv: csv)
  rescue => e
    Failure("CSV validation failed: #{e.message}")
  end

  # Step 3: Process CSV rows
  def process_rows(input)
    file_import = input[:file_import]
    csv = input[:csv]

    csv.each_with_index do |row, index|
      data = row.to_h.merge(file_import_id: file_import.id, row_number: index + 1)

      # Validate row
      validation = ProductRowContract.new.call(data)
      unless validation.success?
        FileImportLog.create!(file_import: file_import, row_number: index + 1, status: "failed", message: "Row validation failed: #{validation.errors.to_h}")
        next
      end

      # Process row using ProductRowService
      ProductRowService.new.call(data)
    end

    Success(file_import)
  end

  # Step 4: Mark FileImport as completed
  def mark_completed(file_import)
    file_import.update(status: "completed")
    Success("FileImport #{file_import.id} completed successfully")
  rescue => e
    Failure("Failed to mark FileImport as completed: #{e.message}")
  end
end