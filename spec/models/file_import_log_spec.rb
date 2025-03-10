require 'rails_helper'

RSpec.describe FileImportLog, type: :model do
  let(:file_import) { create(:file_import) } # Create a FileImport instance

  describe "associations" do
    it { should belong_to(:file_import) }
  end

  describe "validations" do
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending success failed]) }
    it { should validate_presence_of(:message) }
  end

  describe "creating a valid file import log" do
    it "is valid with all attributes" do
      log = build(:file_import_log, file_import: file_import, status: "success", message: "Import completed")
      expect(log).to be_valid
    end

    it "is invalid without a status" do
      log = build(:file_import_log, file_import: file_import, status: nil, message: "Missing status")
      expect(log).not_to be_valid
      expect(log.errors[:status]).to include("can't be blank")
    end

    it "is invalid with an incorrect status" do
      log = build(:file_import_log, file_import: file_import, status: "invalid_status", message: "Wrong status")
      expect(log).not_to be_valid
      expect(log.errors[:status]).to include("is not included in the list")
    end

    it "is invalid without a message" do
      log = build(:file_import_log, file_import: file_import, status: "failed", message: nil)
      expect(log).not_to be_valid
      expect(log.errors[:message]).to include("can't be blank")
    end
  end
end