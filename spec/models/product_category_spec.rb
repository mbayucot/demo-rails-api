require 'rails_helper'

RSpec.describe ProductCategory, type: :model do
  describe "Associations" do
    it { should belong_to(:product) }
    it { should belong_to(:category) }
    it { should belong_to(:user) }
  end

  describe "Validations" do
    it { should validate_presence_of(:product_id) }
    it { should validate_presence_of(:category_id) }
    it { should validate_presence_of(:user_id) }
  end
end