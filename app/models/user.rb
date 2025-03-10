class User < ApplicationRecord
  has_many :stores, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :stores, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :file_imports, dependent: :destroy

  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true, length: { minimum: 2 }

  def full_name
    "#{first_name} #{last_name}"
  end
end
