class StoresController < ApplicationController
  include Pundit
  include ErrorHandler

  before_action :authenticate_user!
  before_action :set_store, only: %i[show update destroy]

  # GET /stores
  def index
    stores = Store.includes(:products)
    authorize stores
    render json: StoreBlueprint.render(stores, view: :extended), status: :ok
  end

  # GET /stores/:id
  def show
    authorize @store
    render json: StoreBlueprint.render(@store, view: :extended), status: :ok
  end

  # POST /stores
  def create
    authorize Store
    store = Store.create!(store_params)
    render json: StoreBlueprint.render(store, view: :extended), status: :created
  end

  # PATCH/PUT /stores/:id
  def update
    authorize @store
    @store.update!(store_params)
    render json: StoreBlueprint.render(@store, view: :extended), status: :ok
  end

  # DELETE /stores/:id
  def destroy
    authorize @store
    @store.destroy
    head :no_content
  end

  private

  def set_store
    @store = Store.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:name, :address)
  end
end