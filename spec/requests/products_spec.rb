require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe "Products API", type: :request do
  let!(:user) { create(:user) }
  let!(:store) { create(:store, user: user) }
  let!(:product) { create(:product, store: store, user: user) }

  let(:valid_headers) do
    Devise::JWT::TestHelpers.auth_headers({ "Accept" => "application/json" }, user)
  end

  describe "GET /stores/:store_id/products" do
    it "returns all products for the user's store" do
      get "/stores/#{store.id}/products", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(1)
    end
  end

  describe "GET /stores/:store_id/products/:id" do
    it "returns the product details" do
      get "/stores/#{store.id}/products/#{product.id}", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(product.id)
    end
  end

  describe "POST /stores/:store_id/products" do
    let(:valid_params) { { name: "New Product", description: "A cool product", price: 49.99 } }
    let(:invalid_params) { { name: "", description: "", price: -10 } }

    fit "creates a product" do
      post "/stores/#{store.id}/products", params: valid_params, headers: valid_headers
      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("New Product")
    end

    it "returns unprocessable entity for invalid input" do
      post "/stores/#{store.id}/products", params: invalid_params, headers: valid_headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["errors"]["name"]).to include("can't be blank", "is too short (minimum is 3 characters)")
      expect(json["errors"]["description"]).to include("can't be blank", "is too short (minimum is 10 characters)")
      expect(json["errors"]["price"]).to include("must be greater than or equal to 0")
    end
  end

  describe "PATCH /stores/:store_id/products/:id" do
    let(:update_params) { { name: "Updated Product" } }

    it "updates the product" do
      patch "/stores/#{store.id}/products/#{product.id}", params: update_params, headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Updated Product")
    end
  end

  describe "DELETE /stores/:store_id/products/:id" do
    it "deletes the product" do
      delete "/stores/#{store.id}/products/#{product.id}", headers: valid_headers
      expect(response).to have_http_status(:no_content)
    end
  end
end