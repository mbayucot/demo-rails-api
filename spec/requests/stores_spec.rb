require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe "Stores API", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) } # For negative test cases

  let(:valid_headers) do
    Devise::JWT::TestHelpers.auth_headers({ "Accept" => "application/json" }, user)
  end

  let(:invalid_headers) do
    { "Accept" => "application/json" } # No JWT token
  end

  let!(:store) { create(:store, user: user) }
  let!(:other_store) { create(:store, user: other_user) }

  describe "GET /stores" do
    it "returns all stores for the logged-in user" do
      get "/stores", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe "GET /stores/:id" do
    it "returns the store details" do
      get "/stores/#{store.id}", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(store.id)
    end
  end

  describe "POST /stores" do
    let(:valid_params) { { name: "New Store", address: "456 Market St" } }
    let(:invalid_params) { { name: "", address: "" } }

    context 'with valid parameters' do
      it "creates a store" do
        post "/stores", params: valid_params, headers: valid_headers
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["name"]).to eq("New Store")
      end
    end

    fcontext 'with invalid parameters' do
      it "returns unprocessable entity for invalid input" do
        post "/stores", params: invalid_params, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include_json('name': ["can't be blank"])
      end
    end
  end

  describe "PATCH /stores/:id" do
    let(:update_params) { { name: "Updated Store Name" } }

    it "updates the store" do
      patch "/stores/#{store.id}", params: update_params, headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq("Updated Store Name")
    end
  end

  describe "DELETE /stores/:id" do
    it "deletes the store" do
      delete "/stores/#{store.id}", headers: valid_headers
      expect(response).to have_http_status(:no_content)
    end
  end
end