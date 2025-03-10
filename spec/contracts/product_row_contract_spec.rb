require 'rails_helper'

RSpec.describe ProductRowContract do
  let(:valid_row) do
    {
      name: "Test Product",
      description: "A high-quality test product",
      price: 19.99,
      store: "Sample Store",
      categories: "Electronics, Gadgets"
    }
  end

  let(:missing_fields) do
    {
      name: "",
      description: "Short",
      price: -5.00,
      store: ""
    }
  end

  let(:invalid_categories) do
    valid_row.merge(categories: "Electronics, @@Gadgets!!")
  end

  let(:contract) { ProductRowContract.new }

  describe ".call" do
    context "when row is valid" do
      it "returns success" do
        result = contract.call(valid_row)
        expect(result).to be_success
      end
    end

    context "when row is missing required fields" do
      it "returns failure with validation errors" do
        result = contract.call(missing_fields)
        expect(result).to be_failure
        expect(result.errors.to_h).to include(:name, :description, :price, :store)
      end
    end

    context "when categories contain invalid characters" do
      it "returns failure" do
        result = contract.call(invalid_categories)
        expect(result).to be_failure
        expect(result.errors.to_h[:categories]).to include("must be a comma-separated list of valid category names")
      end
    end
  end
end