class ProductBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :description, :price, :created_at, :updated_at

  association :store, blueprint: StoreBlueprint
  association :user, blueprint: UserBlueprint
  association :categories, blueprint: CategoryBlueprint

  field :image_url do |product|
    Rails.application.routes.url_helpers.rails_blob_url(product.image, only_path: true) if product.image.attached?
  end
end