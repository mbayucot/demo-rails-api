require 'rails_helper'

RSpec.describe "Stores API", type: :request do
  let!(:admin) { create(:user, role: :admin) }
  let!(:product_manager) { create(:user, role: :product_manager) }
  let!(:regular_user) { create(:user, role: :user) }

  let!(:stores) { create_list(:store, 3) }
  let(:store) { stores.first }

  let(:valid_attributes) do
    {
      store: {
        name: "Updated Store",
        address: "New Address"
      }
    }
  end

  let(:invalid_attributes) do
    { store: { name: "" } } # Invalid name
  end

  describe "GET /stores" do
    it "allows any user to view stores" do
      get "/stores", headers: auth_headers(regular_user)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe "GET /stores/:id" do
    it "allows any user to view a single store" do
      get "/stores/#{store.id}", headers: auth_headers(regular_user)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq(store.name)
    end
  end

  describe "POST /stores" do
    it "allows only admin to create a store" do
      post "/stores", params: { store: { name: "New Store", address: "123 New St" } }, headers: auth_headers(admin)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["name"]).to eq("New Store")
    end

    it "denies regular users from creating a store" do
      post "/stores", params: { store: { name: "New Store", address: "123 New St" } }, headers: auth_headers(regular_user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PUT /stores/:id" do
    it "allows only admin to update a store" do
      put "/stores/#{store.id}", params: valid_attributes, headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq("Updated Store")
    end

    it "denies regular users from updating a store" do
      put "/stores/#{store.id}", params: valid_attributes, headers: auth_headers(regular_user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /stores/:id" do
    it "allows only admin to delete a store" do
      delete "/stores/#{store.id}", headers: auth_headers(admin)

      expect(response).to have_http_status(:no_content)
      expect(Store.exists?(store.id)).to be_falsey
    end

    it "denies regular users from deleting a store" do
      delete "/stores/#{store.id}", headers: auth_headers(regular_user)

      expect(response).to have_http_status(:forbidden)
    end
  end
end