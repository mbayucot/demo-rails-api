require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe "Products API", type: :request do
  let!(:user) { create(:user) }
  let!(:store) { create(:store, user: user) }
  let!(:categories) { create_list(:category, 3) }
  let!(:product) do
    product = create(:product, store: store, user: user)
    product.categories << categories
    product
  end

  let(:valid_headers) do
    Devise::JWT::TestHelpers.auth_headers({ "Accept" => "application/json" }, user)
  end

  describe "GET /stores/:store_id/products" do
    it "returns all products for the store" do
      get "/stores/#{store.id}/products", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(1)
    end
  end

  describe "GET /stores/:store_id/products/:id" do
    it "returns the product details with categories" do
      get "/stores/#{store.id}/products/#{product.id}", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(product.id)
      expect(json["categories"].size).to eq(3) # Ensures categories exist
    end
  end

  describe "POST /stores/:store_id/products" do
    let(:valid_params) { { name: "New Product", description: "A great item", price: 99.99, category_ids: [categories.first.id, categories.last.id] } }
    let(:invalid_params) { { name: "", description: "", price: -10 } }

    it "creates a product with categories" do
      post "/stores/#{store.id}/products", params: valid_params, headers: valid_headers
      puts json["errors"]
      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("New Product")
      expect(json["categories"].size).to eq(2) # Should have 2 categories assigned
    end

    #it "returns unprocessable entity for invalid input" do
    #  post "/stores/#{store.id}/products", params: invalid_params, headers: valid_headers
    #  expect(response).to have_http_status(:unprocessable_entity)
    #  expect(json["errors"]["name"]).to include("can't be blank")
    #  expect(json["errors"]["description"]).to include("can't be blank")
    #  expect(json["errors"]["price"]).to include("must be greater than or equal to 0")
    #end
  end

  describe "PATCH /stores/:store_id/products/:id" do
    let(:update_params) { { name: "Updated Product", category_ids: [categories.second.id] } }
    let(:remove_categories_params) { { category_ids: [] } }

    it "updates the product and assigns new categories" do
      patch "/stores/#{store.id}/products/#{product.id}", params: update_params, headers: valid_headers
      product.reload

      expect(response).to have_http_status(:ok)
      expect(product.name).to eq("Updated Product")
      expect(product.categories.size).to eq(1) # Should be replaced with only the second category
    end

    it "removes all categories from the product" do
      patch "/stores/#{store.id}/products/#{product.id}", params: remove_categories_params, headers: valid_headers
      product.reload

      expect(response).to have_http_status(:ok)
      expect(product.categories).to be_empty
    end

    it "does not change categories if category_ids is not passed" do
      patch "/stores/#{store.id}/products/#{product.id}", params: { name: "No Category Change" }, headers: valid_headers
      product.reload

      expect(response).to have_http_status(:ok)
      expect(product.name).to eq("No Category Change")
      expect(product.categories.size).to eq(3) # Categories should remain unchanged
    end
  end

  describe "DELETE /stores/:store_id/products/:id" do
    it "deletes the product" do
      delete "/stores/#{store.id}/products/#{product.id}", headers: valid_headers
      expect(response).to have_http_status(:no_content)
      expect { product.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end