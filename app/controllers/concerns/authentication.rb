module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :ensure_authenticated_user
    helper_method :current_user
  end

  def current_user
    @current_user ||= authenticate_user(cookies.signed[:user_id].presence)
  end

  private

  def ensure_authenticated_user
    redirect_to(new_session_url) unless current_user
  end

  def authenticate_user(user_id)
    return unless user_id
    if user = User.find_by(id: user_id)
      cookies.signed[:user_id] = user_id
      @current_user = user
    end
  end

  def unauthenticate_user
    @current_user = nil
    cookies.delete(:user_id)
  end
end
