class ProductRowWorker
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: 2, backtrace: true

  def perform(data)
    result = ProductRowService.new.call(data)

    log_result(data, result.success?, result.success? ? "Product '#{data['name']}' imported successfully" : result.failure)
  rescue => e
    log_result(data, false, "Unexpected error: #{e.message}")
    Rails.logger.error("[ProductRowWorker] Error processing row #{data['row_number']}: #{e.message}")
  end

  private

  def log_result(data, success, message)
    FileImportLog.create!(
      file_import_id: data["file_import_id"],
      row_number: data["row_number"],
      status: success ? "success" : "failed",
      message: message
    )
  end
end