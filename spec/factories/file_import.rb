FactoryBot.define do
  factory :file_import do
    association :user
    status { "pending" }
    total_rows { 10 }
    processed_rows { 0 }

    after(:build) do |file_import|
      file_import.file.attach(
        io: File.open(Rails.root.join("spec/fixtures/sample.csv")),
        filename: "sample.csv",
        content_type: "text/csv"
      )
    end
  end
end