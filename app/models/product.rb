class Product < ApplicationRecord
  belongs_to :store
  belongs_to :user

  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end