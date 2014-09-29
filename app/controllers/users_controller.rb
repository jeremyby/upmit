class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show]
  before_action :set_current_user, only: [:update, :account, :profile, :preference, :finish_signup]
  # before_action :ensure_signup_complete, only: [:new, :create, :update]

  def index

  end

  def show

  end

  # PATCH/PUT /users/:id.:format
  def update
    pass = true
    
    params[:user][:slug] = nil if user_params[:username].present? # udating username, therefore need to update slug
    
    # update password, if user has no password, e.g. from Twitter, validations are bypassed, again
    if params[:user].key?(:password) && @user.encrypted_password.present?
      if params[:user][:current_password].blank? # no current password
        pass = false
      elsif @user.valid_password?(params[:user][:current_password])
        pass = false if params[:user][:password] == params[:user][:current_password]  # new password is the same as the current password
      else
        pass = false # current password is not correct
      end
    end
    
    if params[:user].key?(:avatar) # updating avatar
      params[:user].delete(:avatar) if params[:user][:avatar].blank?
      params[:user].delete(:remote_avatar_url) if params[:user][:remote_avatar_url].blank?
    end
    
    respond_to do |format|
      if @user.update(user_params) && pass
        sign_in(current_user.reload, :bypass => true)
        
        format.html { redirect_to @user, notice: 'Your account was successfully updated.' }
        
        if user_params[:username].present?
          format.json { render json: { url: user_url(@user) }}
        elsif user_params[:avatar].present? || user_params[:remote_avatar_url].present?
          format.json { render json: { avatar: @user.avatar.url }}
        else
          format.json { head :no_content }
        end
      else
        unless pass
          if params[:user][:current_password].blank? # no current password
            @user.errors.add(:current_password, "can't be blank" )
          elsif @user.valid_password?(params[:user][:current_password])
            @user.errors.messages[:password] = ["is the same as the current password"] if params[:user][:password] == params[:user][:current_password]
          else
            @user.errors.add(:current_password, "is not correct")
          end
        end
        
        format.html { render action: 'account' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET/PATCH /users/:id/finish_signup
  def finish_signup
    if request.patch? && params[:user]
      if @user.update(user_params)
        if params[:user][:follow_upmit]
          auth = @user.authorizations.where(provider: 'twitter').first
          
          follower = FollowUpmitService.new(auth) # Use a service to follow @upmit and delay it to avoid hold-up
          follower.delay.follow
        end
        
        sign_in(@user, :bypass => true)
        redirect_to root_path, notice: 'Your account was successfully updated.'
      end
    end
  end
  
  def confirmation_sent
  end
  
  #Settings
  def account
    
  end
  
  def profile

  end
  
  def preference
    if request.post? 
      if params[:user][:disconnect].present? && %w(twitter).include?(params[:user][:disconnect]) # disconnecting twitter
        type = params[:user][:disconnect]
        
        auth = @user.authorizations.where(provider: type).first
        reminder = @user.reminders.where(type: "#{ type.capitalize }Reminder").first
        
        Authorization.transaction do
          auth.destroy
          reminder.destroy
        end
        
      elsif params[:user][:reminder].present? # updaing reminder settings
        reminder_params = params[:user][:reminder]
        type = reminder_params[:change]
        
        succeed = true
        
        if %w(twitter email).include?(type)
          reminder = @user.reminders.where(type: "#{ type.capitalize }Reminder").first
        else
          succeed = false
        end
        
        respond_to do |format|
          if reminder.update(state: reminder_params[type]) && succeed
            format.js { head :no_content }
          else
            format.js { head :unprocessable_entity }
          end
        end
      end
    end
  end
  

  private
  def set_user
    @user = User.find_by_slug(params[:id])
  end
  
  def set_current_user
    @user = current_user
  end

  def user_params
    accessible = [ :first_name, :last_name, :username, :email, :timezone, :slug, :password, :password_confirmation, :bio, :avatar, :remote_avatar_url ] # extend with your own params
    params.require(:user).permit(accessible)
  end
  
  def ensure_signup_complete
    # Ensure we don't go into an infinite loop
    return if action_name == 'finish_signup'

    # Redirect to the 'finish_signup' page if the user
    # email hasn't been verified yet
    if current_user && !current_user.email_valid?
      redirect_to finish_signup_path(current_user)
    end
  end
end
