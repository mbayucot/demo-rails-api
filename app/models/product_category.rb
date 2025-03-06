class ProductCategory < ApplicationRecord
  belongs_to :product
  belongs_to :category
  belongs_to :user

  validates :product_id, presence: true
  validates :category_id, presence: true
  validates :user_id, presence: true
end