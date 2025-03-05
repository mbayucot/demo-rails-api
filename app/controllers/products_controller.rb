class ProductsController < ApplicationController
  include Pundit
  include ErrorHandler

  before_action :authenticate_user!
  before_action :set_store
  before_action :set_product, only: %i[show update destroy submit_for_review approve reject discard restore]

  # GET /stores/:store_id/products
  def index
    products = @store.products.with_attached_image.includes(:categories)
                     .paginate(page: params[:page], per_page: 10)
    authorize products
    render json: {
      products: ProductBlueprint.render(products, view: :extended),
      pagination: pagination_meta(products)
    }, status: :ok
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

  # DELETE /stores/:store_id/products/:id (Soft delete)
  def discard
    authorize @product
    @product.discard!
    render json: { message: "Product has been soft deleted" }, status: :ok
  end

  # POST /stores/:store_id/products/:id/restore
  def restore
    authorize @product
    @product.undiscard!
    render json: { message: "Product has been restored" }, status: :ok
  end

  # POST /stores/:store_id/products/:id/submit_for_review
  def submit_for_review
    authorize @product
    @product.submit_for_review!
    render json: { message: "Product submitted for review" }, status: :ok
  end

  # POST /stores/:store_id/products/:id/approve
  def approve
    authorize @product
    @product.approve!
    render json: { message: "Product approved" }, status: :ok
  end

  # POST /stores/:store_id/products/:id/reject
  def reject
    authorize @product
    @product.reject!
    render json: { message: "Product rejected" }, status: :ok
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
end