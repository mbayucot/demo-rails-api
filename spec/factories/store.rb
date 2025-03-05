FactoryBot.define do
  factory :store do
    name { Faker::Company.name }
    address { Faker::Address.street_address }
    association :user
  end
end