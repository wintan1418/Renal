class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_hospital

  def current_hospital
    @current_hospital ||= Hospital.current
  end

  # Cache helper that degrades gracefully if the cache backend is unavailable
  # (e.g. the Solid Cache table isn't set up). Falls back to computing the
  # value directly so a broken cache can never 500 a page.
  def resilient_cache(key, **options)
    Rails.cache.fetch(key, **options) { yield }
  rescue StandardError => e
    Rails.logger.warn("[resilient_cache] #{e.class}: #{e.message}")
    yield
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :phone, :role ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :phone, :avatar ])
  end

  def after_sign_in_path_for(resource)
    case resource.role
    when "admin"         then admin_root_path
    when "doctor", "nurse" then staff_root_path
    when "receptionist"  then receptionist_root_path
    when "patient"       then patient_portal_root_path
    else root_path
    end
  end
end
