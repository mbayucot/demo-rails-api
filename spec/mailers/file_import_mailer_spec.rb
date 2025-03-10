require "rails_helper"

RSpec.describe FileImportMailer, type: :mailer do
  let(:user) { create(:user, email: "test@example.com") }
  let(:file_import) { create(:file_import, user: user) }

  describe "#import_success" do
    let(:mail) { FileImportMailer.import_success(file_import) }

    it "renders the headers" do
      expect(mail.subject).to eq("File Import Completed Successfully")
      expect(mail.to).to eq(["test@example.com"])
      expect(mail.from).to eq(["no-reply@example.com"])
    end
  end

  describe "#import_failed" do
    let(:mail) { FileImportMailer.import_failed(file_import) }

    it "renders the headers" do
      expect(mail.subject).to eq("File Import Failed")
      expect(mail.to).to eq(["test@example.com"])
      expect(mail.from).to eq(["no-reply@example.com"])
    end
  end
end