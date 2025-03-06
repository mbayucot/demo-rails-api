class ProductsController < ApplicationController
  before_action :set_store
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /stores/:store_id/products
  def index
    products = @store.products.includes(:categories)
    render json: ProductBlueprint.render(products), status: :ok
  end

  # GET /stores/:store_id/products/:id
  def show
    render json: ProductBlueprint.render(@product), status: :ok
  end

  # POST /stores/:store_id/products
  def create
    product = @store.products.new(product_params.merge(user: current_user))
    update_categories(product, params[:category_ids])

    product.save!
    render json: ProductBlueprint.render(product), status: :created
  end

  # PATCH/PUT /stores/:store_id/products/:id
  def update
    @product.update!(product_params)
    update_categories(@product, params[:category_ids]) if params.key?(:category_ids)

    render json: ProductBlueprint.render(@product), status: :ok
  end

  # DELETE /stores/:store_id/products/:id
  def destroy
    @product.destroy
    head :no_content
  end

  private

  def set_store
    @store = current_user.stores.find(params[:store_id])
  end

  def set_product
    @product = @store.products.find(params[:id])
  end

  def product_params
    params.permit(:name, :description, :price, category_ids: [])
  end

  def update_categories(product, category_ids)
    return if category_ids.nil?

    valid_categories = Category.where(id: category_ids)
    product.categories = valid_categories
  end
end