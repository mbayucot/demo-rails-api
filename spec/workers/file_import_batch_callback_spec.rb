require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe FileImportBatchCallback, type: :callback do
  let(:user) { create(:user, first_name: "John", last_name: "Doe", email: "test@example.com") }
  let(:file_import) { create(:file_import, user: user, status: "pending") }

  let(:options) { { "file_import_id" => file_import.id } }
  let(:status) { instance_double(Sidekiq::Batch::Status) }

  before do
    allow(FileImportMailer).to receive(:import_success).and_return(double(deliver_later: true))
    allow(FileImportMailer).to receive(:import_failed).and_return(double(deliver_later: true))
  end

  describe "#on_complete" do
    context "when file import has failed logs" do
      before do
        create(:file_import_log, file_import: file_import, status: "failed")
        FileImportBatchCallback.new.on_complete(status, options)
      end

      it "updates the file import status to 'failed'" do
        expect(file_import.reload.status).to eq("failed")
      end

      it "sends the failure email" do
        expect(FileImportMailer).to have_received(:import_failed).with(file_import)
      end
    end

    context "when file import is successful" do
      before do
        create(:file_import_log, file_import: file_import, status: "success")
        FileImportBatchCallback.new.on_complete(status, options)
      end

      it "updates the file import status to 'completed'" do
        expect(file_import.reload.status).to eq("completed")
      end

      it "sends the success email" do
        expect(FileImportMailer).to have_received(:import_success).with(file_import)
      end
    end

    context "when file import is not found" do
      it "does nothing" do
        expect { FileImportBatchCallback.new.on_complete(status, { "file_import_id" => nil }) }
          .not_to change { FileImport.count }
      end
    end
  end
end