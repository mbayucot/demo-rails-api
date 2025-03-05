class ImportProductsJob < ApplicationJob
  queue_as :default

  def perform(store_import_log_id, user_id)
    store_import_log = StoreImportLog.find(store_import_log_id)
    user = User.find(user_id)

    store_import_log.start_processing!

    result = ImportProductsService.call(store_import_log)

    store_import_log.complete! if result.success?

    # Notify user
    ImportNotificationMailer.notify(user.email, store_import_log, result).deliver_later
  rescue => e
    store_import_log.fail!
    ImportNotificationMailer.notify(user.email, store_import_log, "Import failed: #{e.message}").deliver_later
  end
end