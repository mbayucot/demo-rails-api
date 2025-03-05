class StoreImportRow
  include Mongoid::Document
  include AASM

  field :row_data, type: Hash
  field :errors, type: Array, default: []

  embedded_in :store_import_log

  aasm column: :status do
    state :pending, initial: true
    state :valid, :invalid, :processed, :error

    event :validate_row do
      transitions from: :pending, to: :valid, guard: :valid_data?
      transitions from: :pending, to: :invalid, unless: :valid_data?
    end

    event :process_row do
      transitions from: :valid, to: :processed
      transitions from: :valid, to: :error, guard: :has_errors?
    end
  end

  def valid_data?
    errors.empty?
  end

  def has_errors?
    errors.any?
  end
end