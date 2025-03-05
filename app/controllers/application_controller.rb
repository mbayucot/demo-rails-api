class ApplicationController < ActionController::API
  include ErrorHandler
  include Pundit::Authorization

  before_action :authenticate_user!
end
