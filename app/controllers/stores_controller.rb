class StoresController < ApplicationController
  before_action :set_store, only: [:show, :update, :destroy]

  # GET stores
  def index
    stores = current_user.stores
    render json: StoreBlueprint.render(stores), status: :ok
  end

  # GET stores/:id
  def show
    render json: StoreBlueprint.render(@store), status: :ok
  end

  # POST stores
  def create
    store = current_user.stores.create!(store_params)
    render json: StoreBlueprint.render(store), status: :created
  end

  # PATCH/PUT stores/:id
  def update
    @store.update!(store_params)
    render json: StoreBlueprint.render(@store), status: :ok
  end

  # DELETE stores/:id
  def destroy
    @store.destroy
    head :no_content
  end

  private

  def set_store
    @store = current_user.stores.find(params[:id])
  end

  def store_params
    params.permit(:name, :address)
  end
end