class StoreBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :address, :created_at, :updated_at

  association :products, blueprint: ProductBlueprint
end