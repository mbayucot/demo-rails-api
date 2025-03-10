class FileImport < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  include AASM

  aasm column: :status do
    state :pending, initial: true
    state :in_progress
    state :completed
    state :failed

    event :start_import do
      transitions from: :pending, to: :in_progress
    end

    event :mark_completed do
      transitions from: :in_progress, to: :completed, guard: :all_rows_processed?
    end

    event :mark_failed do
      transitions from: [:pending, :in_progress], to: :failed
    end
  end

  def all_rows_processed?
    processed_rows >= total_rows
  end
end