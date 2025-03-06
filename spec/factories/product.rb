FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence(word_count: 10) }
    price { Faker::Commerce.price(range: 1.0..100.0) }
    association :store
    association :user

    #after(:create) do |product, evaluator|
    #  product.categories << create_list(:category, 2) # Ensures join table is used
    #end
  end
end