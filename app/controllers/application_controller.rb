class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  include SearchHelper
end
