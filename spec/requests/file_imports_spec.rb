require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe "FileImports API", type: :request do
  let!(:user) { create(:user) }
  let!(:file_import) { create(:file_import, user: user) }

  let(:valid_headers) do
    Devise::JWT::TestHelpers.auth_headers({ "Accept" => "application/json" }, user)
  end

  let(:invalid_headers) do
    { "Accept" => "application/json" } # No JWT token
  end

  describe "GET /file_imports" do
    it "returns all file imports" do
      get "/file_imports", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to be >= 1
    end
  end

  describe "POST /file_imports" do
    let(:valid_file) { fixture_file_upload(Rails.root.join("spec/fixtures/sample.csv"), "text/csv") }
    let(:invalid_file) { nil }

    context "with a valid file" do
      it "creates a file import and starts processing" do
        post "/file_imports", params: { file: valid_file }, headers: valid_headers
        expect(response).to have_http_status(:accepted)
        expect(JSON.parse(response.body)["message"]).to eq("File import started")
      end
    end

    context "without a file" do
      it "returns an error" do
        post "/file_imports", params: { file: invalid_file }, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("File is required")
      end
    end
  end
end