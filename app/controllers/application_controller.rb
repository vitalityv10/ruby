class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from StandardError, with: :handle_internal_error if Rails.env.production?
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_bad_request
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_conflict
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record

  helper_method :current_user, :logged_in?, :authenticate_user!, :require_admin!

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def authenticate_user!
    return if logged_in?
    redirect_to login_path, alert: "Спочатку потрібно увійти."
  end

  def require_admin!
    return redirect_to(login_path, alert: "Спочатку потрібно увійти.") unless logged_in?
    redirect_to root_path, alert: "Не знайдено." unless current_user.admin?
  end

  private

  def handle_not_found(exception)
    Rails.logger.warn("Not found: #{exception.message}")
    respond_with_error "Сторінку або запис не знайдено.", :not_found, "public/404.html"
  end

  def handle_bad_request(exception)
    Rails.logger.warn("Bad request: #{exception.message}")
    respond_with_error "Некоректний запит.", :bad_request, "public/400.html"
  end

  def handle_conflict(exception)
    Rails.logger.warn("Conflict: #{exception.message}")
    respond_with_error "Такий запис уже існує.", :conflict, "public/422.html"
  end

  def handle_invalid_record(exception)
    respond_with_error exception.record.errors.full_messages.to_sentence, :unprocessable_entity, "public/422.html"
  end

  def handle_internal_error(exception)
    Rails.logger.error("#{exception.class}: #{exception.message}\n#{exception.backtrace&.first(10)&.join("\n")}")
    respond_with_error "Сталася внутрішня помилка. Спробуйте пізніше.", :internal_server_error, "public/500.html"
  end

  def respond_with_error(message, status, _page)
    respond_to do |format|
      format.html { redirect_back_or_to root_path, alert: message }
      format.json { render json: { error: message }, status: status }
      format.any  { head status }
    end
  end
end
