require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "Validations" do
    subject { create(:category) } # Ensures uniqueness tests work properly

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(50) }
  end
end