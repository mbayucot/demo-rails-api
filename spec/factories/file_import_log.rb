FactoryBot.define do
  factory :file_import_log do
    association :file_import
    row_number { Faker::Number.between(from: 1, to: 100) }
    status { %w[pending success failed].sample } # Randomly select a valid status
    message { Faker::Lorem.sentence(word_count: 10) }
  end
end