require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe FileImportWorker, type: :worker do
  let(:file_import) { create(:file_import, file: fixture_file_upload('sample.csv', 'text/csv')) }

  before do
    allow(LoaderWorker).to receive(:perform_async)
  end

  describe "#perform" do
    it "marks file_import as in_progress" do
      expect {
        described_class.new.perform(file_import.id)
        file_import.reload
      }.to change { file_import.status }.from("pending").to("in_progress")
    end

    it "creates a Sidekiq batch for processing" do
      expect(Sidekiq::Batch).to receive(:new).and_call_original

      described_class.new.perform(file_import.id)
    end

    it "enqueues LoaderWorker jobs in batches" do
      described_class.new.perform(file_import.id)

      expect(LoaderWorker).to have_received(:perform_async).at_least(:once)
    end
  end
end