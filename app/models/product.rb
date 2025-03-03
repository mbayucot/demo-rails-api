class Product < ApplicationRecord
  belongs_to :store
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  has_one_attached :image # Active Storage attachment

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end