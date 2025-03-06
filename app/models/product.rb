class Product < ApplicationRecord
  belongs_to :store
  belongs_to :user

  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  has_one_attached :image # Add this line for Active Storage

  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end