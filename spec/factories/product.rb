FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence(word_count: 10) }
    price { Faker::Commerce.price(range: 1.0..100.0) }
    association :store
    association :user

    after(:create) do |product|
      create_list(:product_category, 2, product: product, category: create(:category))
    end
  end
end