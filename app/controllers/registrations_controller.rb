class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:first_name, :last_name,
        :email, :password, :password_confirmation, :timezone)
    end
    
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:name,
        :email, :password, :password_confirmation, :current_password)
    end
  end

  def after_sign_up_path_for(resource)
    root_path
  end
  
  def after_inactive_sign_up_path_for(resource)
    confirmation_sent_path
  end
end
