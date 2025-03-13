class ApplicationController < ActionController::API
  include ErrorHandler
  include Paginatable
  include Pundit::Authorization

  before_action :authenticate_user!
end
