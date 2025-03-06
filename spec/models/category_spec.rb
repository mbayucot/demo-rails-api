require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "Associations" do
    it { should have_many(:product_categories).dependent(:destroy) }
    it { should have_many(:products).through(:product_categories) }
  end

  describe "Validations" do
    subject { create(:category) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(50) }
  end
end