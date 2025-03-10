require 'rails_helper'

RSpec.describe ProductRowWorker, type: :worker do
  let(:file_import) { create(:file_import) }
  let(:valid_data) do
    {
      "file_import_id" => file_import.id,
      "row_number" => 1,
      "name" => "Test Product",
      "description" => "A high-quality test product",
      "price" => 19.99,
      "store" => "Test Store",
      "categories" => "Electronics, Gadgets"
    }
  end

  let(:invalid_data) do
    valid_data.merge("name" => "", "price" => -5)
  end

  before do
    allow(ProductRowService).to receive(:new).and_return(product_row_service)
  end

  let(:product_row_service) { instance_double(ProductRowService) }

  describe "#perform" do
    context "when product row is valid" do
      before do
        allow(product_row_service).to receive(:call).with(valid_data).and_return(Dry::Monads::Result::Success.new(valid_data))
      end

      it "logs success in FileImportLog" do
        expect {
          described_class.new.perform(valid_data)
        }.to change { FileImportLog.count }.by(1)

        log = FileImportLog.last
        expect(log.status).to eq("success")
        expect(log.message).to eq("Product 'Test Product' imported successfully")
      end
    end

    context "when product row is invalid" do
      before do
        allow(product_row_service).to receive(:call).with(invalid_data).and_return(Dry::Monads::Result::Failure.new("Validation failed"))
      end

      it "logs failure in FileImportLog" do
        expect {
          described_class.new.perform(invalid_data)
        }.to change { FileImportLog.count }.by(1)

        log = FileImportLog.last
        expect(log.status).to eq("failed")
        expect(log.message).to eq("Validation failed")
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(product_row_service).to receive(:call).and_raise(StandardError, "Something went wrong")
      end

      it "logs the error in FileImportLog" do
        expect {
          described_class.new.perform(valid_data)
        }.to change { FileImportLog.count }.by(1)

        log = FileImportLog.last
        expect(log.status).to eq("failed")
        expect(log.message).to include("Unexpected error: Something went wrong")
      end
    end
  end
end