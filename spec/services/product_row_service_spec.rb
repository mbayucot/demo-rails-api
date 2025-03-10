require 'rails_helper'

RSpec.describe ProductRowService do
  let(:store) { create(:store, name: "Sample Store") }
  let(:category1) { create(:category, name: "Electronics") }
  let(:category2) { create(:category, name: "Gadgets") }

  let(:valid_data) do
    {
      name: "Test Product",
      description: "A high-quality test product",
      price: 19.99,
      store: store.name,
      categories: "Electronics, Gadgets",
      file_import_id: 1,
      row_number: 1
    }
  end

  let(:invalid_data) do
    {
      name: "",
      description: "Short",
      price: -5.00,
      store: "",
      categories: "",
      file_import_id: 1,
      row_number: 1
    }
  end

  let(:service) { ProductRowService.new }

  describe "#validate_row" do
    it "validates a correct row successfully" do
      result = service.validate_row(valid_data)
      expect(result).to be_success
    end

    it "fails validation for an incorrect row" do
      result = service.validate_row(invalid_data)
      expect(result).to be_failure
      expect(result.failure).to include("Validation failed")
    end
  end

  describe "#validate_store" do
    it "finds the store successfully" do
      result = service.validate_store(valid_data)
      expect(result).to be_success
      expect(result.success[:store]).to eq(store)
    end

    it "fails when the store does not exist" do
      data = valid_data.merge(store: "Nonexistent Store")
      result = service.validate_store(data)
      expect(result).to be_failure
      expect(result.failure).to eq("Store 'Nonexistent Store' not found")
    end
  end

  describe "#validate_and_create_categories" do
    it "assigns existing categories" do
      category1
      category2
      result = service.validate_and_create_categories(valid_data)
      expect(result).to be_success
      expect(result.success[:categories].map(&:name)).to contain_exactly("Electronics", "Gadgets")
    end

    it "creates new categories if they do not exist" do
      data = valid_data.merge(categories: "NewCategory")
      result = service.validate_and_create_categories(data)
      expect(result).to be_success
      expect(Category.exists?(name: "NewCategory")).to be true
    end
  end

  describe "#insert_product" do
    it "creates a product successfully" do
      valid_data[:store] = store
      valid_data[:categories] = [category1, category2]

      result = service.insert_product(valid_data)
      expect(result).to be_success
      expect(Product.exists?(name: "Test Product")).to be true
    end

    it "fails if product is invalid" do
      invalid_product_data = valid_data.merge(name: "", store: store, categories: [category1, category2])
      result = service.insert_product(invalid_product_data)
      expect(result).to be_failure
      expect(result.failure).to include("Product insertion failed")
    end
  end

  describe "#log_success" do
    it "logs a successful import" do
      product = create(:product, name: "Test Product", store: store)
      result = service.log_success(product)
      expect(result).to be_success
      expect(FileImportLog.exists?(message: "Product 'Test Product' imported successfully")).to be true
    end
  end
end