class ProductsController < ApplicationController
  before_action :set_store
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /stores/:store_id/products
  def index
    products = @store.products
    render json: ProductBlueprint.render(products), status: :ok
  end

  # GET /stores/:store_id/products/:id
  def show
    render json: ProductBlueprint.render(@product), status: :ok
  end

  # POST /stores/:store_id/products
  def create
    product = @store.products.create!(product_params.merge(user: current_user))
    render json: ProductBlueprint.render(product), status: :created
  end

  # PATCH/PUT /stores/:store_id/products/:id
  def update
    @product.update!(product_params)
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
    params.permit(:name, :description, :price)
  end
end