class StoreImportLog
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  field :store_id, type: Integer
  field :file_url, type: String
  field :total_records, type: Integer, default: 0
  field :processed_records, type: Integer, default: 0
  field :error_records, type: Integer, default: 0

  embeds_many :store_import_rows

  aasm column: :status do
    state :pending, initial: true
    state :processing, :completed, :failed

    event :start_processing do
      transitions from: :pending, to: :processing
    end

    event :complete do
      transitions from: :processing, to: :completed
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end
end