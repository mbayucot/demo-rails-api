require 'rails_helper'

RSpec.describe ProductRowValidator do
  let(:valid_row) do
    {
      "name" => "Sample Product",
      "description" => "A great product",
      "price" => "19.99",
      "store" => "Test Store",
      "categories" => "Electronics, Gadgets"
    }
  end

  let(:invalid_row_missing_fields) do
    {
      "name" => "",
      "description" => "Short",
      "price" => nil,
      "store" => nil
    }
  end

  let(:invalid_row_price_negative) do
    {
      "name" => "Test Product",
      "description" => "Valid description",
      "price" => "-5.00",
      "store" => "Test Store"
    }
  end

  describe ".call" do
    context "when row is valid" do
      it "returns success" do
        result = ProductRowValidator.call(valid_row)
        expect(result[:success]).to be true
      end
    end

    context "when row is missing required fields" do
      it "returns failure with validation errors" do
        result = ProductRowValidator.call(invalid_row_missing_fields)
        expect(result[:success]).to be false
        expect(result[:error]).to include(:name, :price, :store)
      end
    end

    context "when price is negative" do
      it "returns failure" do
        result = ProductRowValidator.call(invalid_row_price_negative)
        expect(result[:success]).to be false
        expect(result[:error]).to include(:price)
      end
    end
  end
end