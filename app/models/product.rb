class Product < ApplicationRecord
  include AASM
  include Discard::Model
  include PgSearch::Model

  belongs_to :store
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  has_one_attached :image # Active Storage attachment

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  pg_search_scope :search_by_name_and_description,
                  against: [:name, :description],
                  using: {
                    tsearch: { prefix: true }, # Allows partial word matches
                    trigram: {} # Enables fuzzy matching
                  }

  # Locking Mechanism to Prevent Race Conditions
  before_update :lock_row_for_update

  # AASM state machine
  aasm column: :state do
    state :draft, initial: true
    state :pending_review, :approved, :rejected

    event :submit_for_review do
      transitions from: :draft, to: :pending_review, guard: :valid_for_submission?
    end

    event :approve do
      transitions from: :pending_review, to: :approved, guard: :valid_for_approval?
    end

    event :reject do
      transitions from: :pending_review, to: :rejected
    end
  end

  private

    # Ensure product meets criteria before being submitted for review
    def valid_for_submission?
      price.positive? && store.present?
    end

    # Prevent approval if the product was already rejected in another process
    def valid_for_approval?
      aasm.current_state == :pending_review
    end

    # Lock the row to prevent concurrent updates (Race Condition Prevention)
    def lock_row_for_update
      self.class.where(id: id).select(:id).lock(true)
    end
end