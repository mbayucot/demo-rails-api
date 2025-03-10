require 'rails_helper'

RSpec.describe CsvValidator do
  let(:valid_headers) { %w[name description price store categories] }
  let(:missing_headers) { %w[name price store] } # Missing description, categories
  let(:extra_headers) { %w[name description price store categories extra_column] }

  describe ".call" do
    context "when headers are valid" do
      it "returns success" do
        result = CsvValidator.call(valid_headers)
        expect(result[:success]).to be true
      end
    end

    context "when headers are missing required fields" do
      it "returns failure with missing headers" do
        result = CsvValidator.call(missing_headers)
        expect(result[:success]).to be false
        expect(result[:error]).to include("Missing headers: description, categories")
      end
    end

    context "when there are extra unexpected headers" do
      it "returns failure with extra headers" do
        result = CsvValidator.call(extra_headers)
        expect(result[:success]).to be false
        expect(result[:error]).to include("Unexpected headers: extra_column")
      end
    end
  end
end