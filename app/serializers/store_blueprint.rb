class StoreBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :address, :created_at, :updated_at

  association :user, blueprint: UserBlueprint
end