class ProductsController < ApplicationController
  include Pundit
  include ErrorHandler

  before_action :authenticate_user!
  before_action :set_store
  before_action :set_product, only: %i[show update destroy]

  # GET /stores/:store_id/products
  def index
    products = @store.products.with_attached_image.includes(:categories)
    authorize products
    render json: ProductBlueprint.render(products, view: :extended), status: :ok
  end

  # GET /stores/:store_id/products/:id
  def show
    authorize @product
    render json: ProductBlueprint.render(@product, view: :extended), status: :ok
  end

  # POST /stores/:store_id/products
  def create
    authorize Product
    product = @store.products.create!(product_params)
    attach_image(product, params[:image])
    update_categories(product, params[:category_ids])
    render json: ProductBlueprint.render(product, view: :extended), status: :created
  end

  # PATCH/PUT /stores/:store_id/products/:id
  def update
    authorize @product
    @product.update!(product_params)
    attach_image(@product, params[:image])
    update_categories(@product, params[:category_ids])
    render json: ProductBlueprint.render(@product, view: :extended), status: :ok
  end

  # DELETE /stores/:store_id/products/:id
  def destroy
    authorize @product
    @product.destroy
    head :no_content
  end

  private

  def set_store
    @store = Store.find(params[:store_id])
  end

  def set_product
    @product = @store.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price)
  end

  def attach_image(product, image_param)
    return unless image_param.present?

    product.image.attach(image_param)
  end
end