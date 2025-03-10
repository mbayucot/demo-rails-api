class FileImportLog
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "file_import_logs" # Explicitly set collection name

  field :file_import_id, type: Integer
  field :row_number, type: Integer
  field :status, type: String, default: "pending" # success, failed
  field :message, type: String
end