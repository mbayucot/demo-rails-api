require 'rails_helper'

RSpec.describe CsvContract do
  let(:valid_headers) { %w[store name description price categories] }
  let(:missing_headers) { %w[store name price categories] } # Missing 'description'
  let(:extra_headers) { %w[store name description price categories extra_column] }
  let(:invalid_headers_type) { "store, name, description, price, categories" } # Not an array
  let(:empty_headers) { [] }

  let(:contract) { CsvContract.new }

  describe ".call" do
    context "when headers are valid" do
      it "returns success" do
        result = contract.call(headers: valid_headers)
        expect(result).to be_success
      end
    end

    context "when headers are missing required fields" do
      it "returns failure with missing headers message" do
        result = contract.call(headers: missing_headers)
        expect(result).to be_failure
        expect(result.errors.to_h[:headers]).to include("Missing headers: description")
      end
    end

    context "when extra headers are present" do
      it "returns failure with unexpected headers message" do
        result = contract.call(headers: extra_headers)
        expect(result).to be_failure
        expect(result.errors.to_h[:headers]).to include("Unexpected headers: extra_column")
      end
    end

    context "when headers are not an array" do
      it "returns failure with validation error" do
        result = contract.call(headers: invalid_headers_type)
        expect(result).to be_failure
        expect(result.errors.to_h[:headers]).to include("must be an array")
      end
    end

    context "when headers are empty" do
      it "returns failure with validation error" do
        result = contract.call(headers: empty_headers)
        expect(result).to be_failure
        expect(result.errors.to_h[:headers]).to include("must be filled")
      end
    end
  end
end