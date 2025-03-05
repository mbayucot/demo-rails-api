require 'rails_helper'

RSpec.describe "Products API", type: :request do
  let!(:admin) { create(:user, role: :admin) }
  let!(:product_manager) { create(:user, role: :product_manager) }
  let!(:regular_user) { create(:user, role: :user) }

  let!(:store) { create(:store) }
  let!(:products) { create_list(:product, 30, store: store) } # More products for pagination
  let!(:product) { create(:product, store: store, categories: categories) }

  let(:valid_attributes) do
    {
      product: {
        name: "New Product",
        description: "A test product",
        price: 99.99
      },
      category_ids: categories.map(&:id)
    }
  end

  let(:invalid_attributes) do
    { product: { name: "", price: -10 } } # Invalid name and price
  end

  describe "GET /stores/:store_id/products" do
    it "returns paginated products" do
      get "/stores/#{store.id}/products?page=1", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["products"].size).to eq(10) # Per page = 10
      expect(json_response["pagination"]["total_pages"]).to be > 1
    end
  end

  describe "GET /stores/:store_id/products/:id" do
    it "allows any user to view a single product" do
      get "/stores/#{store.id}/products/#{product.id}", headers: auth_headers(regular_user)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq(product.name)
    end
  end

  describe "POST /stores/:store_id/products" do
    it "allows product managers and admins to create a product" do
      post "/stores/#{store.id}/products", params: valid_attributes, headers: auth_headers(product_manager)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["name"]).to eq("New Product")
    end

    it "denies regular users from creating a product" do
      post "/stores/#{store.id}/products", params: valid_attributes, headers: auth_headers(regular_user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PUT /stores/:store_id/products/:id" do
    it "allows product managers and admins to update a product" do
      put "/stores/#{store.id}/products/#{product.id}", params: { product: { name: "Updated Name" } }, headers: auth_headers(product_manager)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq("Updated Name")
    end

    it "denies regular users from updating a product" do
      put "/stores/#{store.id}/products/#{product.id}", params: { product: { name: "Updated Name" } }, headers: auth_headers(regular_user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /stores/:store_id/products/:id" do
    it "allows product managers and admins to delete a product" do
      delete "/stores/#{store.id}/products/#{product.id}", headers: auth_headers(product_manager)

      expect(response).to have_http_status(:no_content)
      expect(Product.exists?(product.id)).to be_falsey
    end

    it "denies regular users from deleting a product" do
      delete "/stores/#{store.id}/products/#{product.id}", headers: auth_headers(regular_user)

      expect(response).to have_http_status(:forbidden)
    end
  end
end