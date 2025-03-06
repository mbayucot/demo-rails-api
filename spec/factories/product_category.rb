FactoryBot.define do
  factory :product_category do
    association :product
    association :category
    association :user
  end
end