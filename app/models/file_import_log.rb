class FileImportLog < ApplicationRecord
  belongs_to :file_import

  validates :status, presence: true, inclusion: { in: %w[pending success failed] }
  validates :message, presence: true
end