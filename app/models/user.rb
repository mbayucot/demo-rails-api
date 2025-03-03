class User < ApplicationRecord
  enum role: { user: 0, product_manager: 1, admin: 2 }

  # Ensure role exists
  validates :role, presence: true
end