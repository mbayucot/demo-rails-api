class Store < ApplicationRecord
  has_paper_trail

  has_many :products, dependent: :destroy

  validates :name, presence: true
end