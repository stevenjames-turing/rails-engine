class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  include ParamVerifier
  include Paginator
end
