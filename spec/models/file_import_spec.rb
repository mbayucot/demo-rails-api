require 'rails_helper'

RSpec.describe FileImport, type: :model do
  let(:user) { User.create!(email: "test@example.com", password: "password") }
  let(:file_import) { FileImport.create!(user: user, status: "pending", total_rows: 10) }

  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(file_import).to be_valid
    end

    it "is invalid without a user" do
      file_import.user = nil
      expect(file_import).not_to be_valid
    end
  end

  describe "state transitions" do
    it "changes state from pending to in_progress" do
      file_import.start_import!
      expect(file_import).to be_in_progress
    end

    it "changes state from in_progress to completed when all rows are processed" do
      file_import.start_import! # ✅ Ensure transition to in_progress
      file_import.update!(processed_rows: 10)
      file_import.mark_completed! # ✅ Now we can call mark_completed!
      expect(file_import).to be_completed
    end

    it "changes state to failed if errors occur" do
      file_import.start_import! # ✅ Ensure transition to in_progress
      file_import.mark_failed!
      expect(file_import).to be_failed
    end
  end
end