class ProductBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :description, :price, :created_at, :updated_at

  association :store, blueprint: StoreBlueprint
  association :user, blueprint: UserBlueprint
  association :categories, blueprint: CategoryBlueprint
end