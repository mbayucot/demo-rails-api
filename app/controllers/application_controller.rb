class ApplicationController < ActionController::API
  include ErrorHandler
  include Pundit::Authorization
end
