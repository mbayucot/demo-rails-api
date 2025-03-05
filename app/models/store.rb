class Store < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :address, presence: true, length: { minimum: 3, maximum: 50 }
end