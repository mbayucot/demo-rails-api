class ProductRowWorker
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: 2, backtrace: true

  def perform(data)
    result = ProductRowService.new.call(data)

    unless result.success?
      FileImportLog.create!(
        file_import_id: data["file_import_id"],
        row_number: data["row_number"],
        status: "failed",
        message: result.failure
      )
    end
  end
end