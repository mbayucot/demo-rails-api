class ImportNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, store_import_log_id)
    user = User.find(user_id)
    store_import_log = StoreImportLog.find(store_import_log_id)

    ImportNotificationMailer.notify(user.email, store_import_log).deliver_later
  end
end