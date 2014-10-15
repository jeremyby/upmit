class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable
  
  def all
    auth = env["omniauth.auth"]
    @user = User.find_for_oauth(auth, current_user)
    
    logger.info auth.info.inspect
    
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      session[:provider] = auth.provider
      set_flash_message(:notice, :success, kind: "#{ auth.provider }".capitalize) if is_navigational_format?
    elsif @user.errors[:auth].present?
      flash[:alert] = @user.errors[:auth][0]
      redirect_to preference_users_path
    else
      session["devise.#{ auth.provider }_data"] = auth
      redirect_to signin_path
    end
  end
  
  alias_method :twitter, :all
  alias_method :facebook, :all
  
  def after_sign_in_path_for(resource)
    unless resource.timezone.blank?
      super resource
    else
      finish_signup_path
    end
  end
  
  def after_omniauth_failure_path_for(resource)
    signin_path
  end
end
