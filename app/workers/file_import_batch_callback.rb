class FileImportBatchCallback
  include Sidekiq::Batch::Callback

  def on_complete(status, options)
    file_import = FileImport.find_by(id: options["file_import_id"])
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