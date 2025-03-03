class ProductBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :description, :price, :created_at, :updated_at

  association :categories, blueprint: CategoryBlueprint

  field :image_url do |product|
    product.image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(product.image, only_path: true) : nil
  end
end