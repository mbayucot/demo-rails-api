class FileImportsController < ApplicationController
  # GET /file_imports
  def index
    file_imports = FileImport.order(created_at: :desc)
    render json: file_imports, status: :ok
  end

  # POST /file_imports
  def create
    file_import = current_user.file_imports.create!(file_import_params)

    if file_import.file.attached?
      file_import.start_import!
      FileImportWorker.perform_async(file_import.id)
      render json: { message: "File import started", file_import: file_import }, status: :accepted
    else
      render json: { error: "File is required" }, status: :unprocessable_entity
    end
  end

  private

  def file_import_params
    params.permit(:file)
  end
end