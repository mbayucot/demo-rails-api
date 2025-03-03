module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from ActionController::RoutingError, with: :render_not_found
    rescue_from StandardError, with: :render_internal_server_error
  end

  private

  def render_not_found(exception)
    render json: { error: 'Not Found', message: exception.message }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    render json: { error: 'Unprocessable Entity', message: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_internal_server_error(exception)
    render json: { error: 'Internal Server Error', message: exception.message }, status: :internal_server_error
  end
end