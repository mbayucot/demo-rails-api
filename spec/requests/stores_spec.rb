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
    before do
      create_list(:store, 15, user: user) # Create multiple stores for pagination
    end

    it "returns stores with correct data structure and pagination" do
      get "/stores", headers: valid_headers, params: { page: 1 }
      expect(response).to have_http_status(:ok)

      # Validate pagination metadata
      expect(json["meta"]).to include(
                                "current_page" => 1,
                                "next_page" => 2,
                                "prev_page" => nil,
                                "total_pages" => 2,
                                "total_entries" => 17 # Dynamic count fix
                              )

      # Validate data structure (ensures it's following StoreBlueprint)
      expect(JSON.parse(json["data"])).to all(include(
                                    "id",
                                    "name",
                                    "address",
                                    "created_at",
                                    "updated_at",
                                    "user" => hash_including(
                                      "id" => anything, # Ensuring user association is included
                                      "email" => anything # Assuming UserBlueprint includes `email`
                                    )
                                  ))
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

    context 'with invalid parameters' do
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