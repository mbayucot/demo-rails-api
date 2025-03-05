class Store < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :address, presence: true, length: { minimum: 3, maximum: 50 }
end