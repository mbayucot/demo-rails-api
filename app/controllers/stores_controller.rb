class StoresController < ApplicationController
  include Pundit
  include ErrorHandler

  before_action :authenticate_user!
  before_action :set_store, only: %i[show update destroy]

  # GET /stores
  def index
    stores = Store.includes(:products).paginate(page: params[:page], per_page: 10)
    authorize stores
    render json: {
      stores: StoreBlueprint.render(stores, view: :extended),
      pagination: pagination_meta(stores)
    }, status: :ok
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

  # POST /stores/:id/import_products
  def import_products
    authorize @store
    return render json: { error: "File is required" }, status: :unprocessable_entity if params[:file].blank?

    file_url = upload_to_s3(params[:file])

    # Create Import Log in MongoDB
    store_import_log = StoreImportLog.create!(
      store_id: @store.id,
      file_url: file_url,
      total_records: 0
    )

    ImportProductsJob.perform_later(store_import_log.id, current_user.id)

    render json: { message: "Import started. You will receive an email when done." }, status: :accepted
  end

  private

  def set_store
    @store = Store.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:name, :address)
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_entries: collection.total_entries
    }
  end
end