class ProductImportService
  include Dry::Transaction

  step :validate_row
  step :validate_store
  step :validate_and_create_categories
  step :insert_product
  step :log_success

  # Step 1: Validate row data
  def validate_row(input)
    contract = ProductRowContract.new
    result = contract.call(input)

    return Success(result.to_h) if result.success?

    log_and_fail(input, "Validation failed: #{result.errors.to_h}")
  end

  # Step 2: Validate store existence
  def validate_store(data)
    store = Store.select(:id, :name).find_by("LOWER(name) = ?", data[:store].downcase)
    return log_and_fail(data, "Store '#{data[:store]}' not found") unless store

    data[:store] = store
    Success(data)
  end

  # Step 3: Validate existing categories and create missing ones
  def validate_and_create_categories(data)
    category_names = data[:categories].to_s.split(',').map(&:strip).uniq

    # Find existing categories (case-insensitive)
    existing_categories = Category.where("LOWER(name) IN (?)", category_names.map(&:downcase))
                                  .select(:id, :name)

    existing_names = existing_categories.map { |c| c.name.downcase }

    # Identify and create missing categories
    new_categories = category_names.reject { |name| existing_names.include?(name.downcase) }
                                   .map { |name| Category.create!(name: name) }

    data[:categories] = existing_categories + new_categories
    Success(data)
  rescue => e
    log_and_fail(data, "Category validation failed: #{e.message}")
  end

  # Step 4: Insert product within a transaction
  def insert_product(data)
    ActiveRecord::Base.transaction do
      product = Product.create!(
        name: data[:name],
        description: data[:description],
        price: data[:price],
        store: data[:store],
        categories: data[:categories]
      )
      Success(product)
    end
  rescue ActiveRecord::RecordInvalid => e
    log_and_fail(data, "Product insertion failed: #{e.record.errors.full_messages.join(', ')}")
  rescue => e
    log_and_fail(data, "Unexpected error during product insertion: #{e.message}")
  end

  # Step 5: Log success
  def log_success(product)
    FileImportLog.create!(
      file_import_id: product.id,
      row_number: nil,
      status: "success",
      message: "Product '#{product.name}' imported successfully"
    )
    Success(product)
  end

  private

  # Optimized error logging and failure response
  def log_and_fail(data, message)
    FileImportLog.create!(
      file_import_id: data[:file_import_id],
      row_number: data[:row_number] || nil,
      status: "failed",
      message: message
    )
    Failure(message)
  rescue => e
    Rails.logger.error("Failed to log error to FileImportLog: #{e.message}")
    Failure("Logging error: #{message}")
  end
end