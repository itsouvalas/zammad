module ApplicationController::PreventsCsrf
  extend ActiveSupport::Concern

  included do
    before_action :verify_csrf_token
    after_action  :set_csrf_token_headers
  end

  private

  def set_csrf_token_headers
    return true if @_auth_type.present? && @_auth_type != 'session'
    headers['CSRF-TOKEN'] = form_authenticity_token
  end

  def verify_csrf_token
    return true if request.method != 'POST' && request.method != 'PUT' && request.method != 'DELETE' && request.method != 'PATCH'
    return true if @_auth_type == 'token_auth' || @_auth_type == 'basic_auth'
    return true if valid_authenticity_token?(session, params[:authenticity_token] || request.headers['X-CSRF-Token'])
    logger.info 'CSRF token verification failed'
    raise Exceptions::NotAuthorized, 'CSRF token verification failed!'
  end
end
