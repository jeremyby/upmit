class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    auth = env["omniauth.auth"]
    @user = User.find_for_oauth(auth, current_user)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "#{ auth.info.provider }".capitalize) if is_navigational_format?
    else
      session["devise.#{ auth.info.provider }_data"] = auth
      redirect_to new_user_registration_url
    end
  end
  
  alias_method :twitter, :all
  
  def after_sign_in_path_for(resource)
    if resource.email_valid?
      super resource
    else
      finish_signup_path(resource)
    end
  end
end
