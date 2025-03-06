require 'rails_helper'

RSpec.describe ProductCategory, type: :model do
  describe "Associations" do
    it { should belong_to(:product) }
    it { should belong_to(:category) }
  end
end