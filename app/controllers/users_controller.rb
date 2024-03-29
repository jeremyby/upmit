class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_user, only: [:update, :account, :profile, :preference, :finish_signup]
  # before_action :ensure_signup_complete, only: [:new, :create, :update]

  def index

  end

  def show
    begin
      @user = User.find_by_slug!(params[:id])

      render 'goals/index' and return
    rescue
      go_404
    end
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
      params[:user].delete(:email) if params[:user][:email].blank?

      if @user.update(user_params)
        if params[:user][:follow_upmit]
          auth = @user.authorizations.find_by(provider: session[:provider])

          follower = FollowUpmitService.new(auth)
          follower.delay.follow
        end

        sign_in(@user, :bypass => true)
        redirect_to root_path, notice: "Your account from #{ session[:provider].capitalize } is now ready."
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
    providers = %w(twitter facebook)

    if request.post?
      if params[:sms_remove] == 'true'
        @reminder = current_user.reminders.find_by(type: "SmsReminder")
        
        @reminder.destroy
        
        flash[:notice] = "Your phone number #{ @reminder.recipient_id } is removed."
        redirect_to '/settings/preference'
        
      elsif params[:user][:switch_to].present? && providers.include?(params[:user][:switch_to]) # switching check-in social network
        type = params[:user][:switch_to]
        providers.delete(type)
        auth = @user.authorizations.find_by(provider: type)

        if auth.present?
          if @user.goals.active.where(checkin_with: providers[0]).blank?
            @user.update_attribute(:checkin_with, type)
          else
            flash.now[:alert] = "There are goals listening for check-ins from #{ providers[0].capitalize }. You can switch form #{ providers[0].capitalize } after they are all completed."
          end
        end
      elsif params[:user][:disconnect].present? && providers.include?(params[:user][:disconnect]) # disconnecting social networks
        type = params[:user][:disconnect]

        auth = @user.authorizations.find_by(provider: type)
        reminder = @user.reminders.find_by(type: "#{ type.capitalize }Reminder")

        if auth.present?
          if @user.authorizations.size <= 1
            flash.now[:alert] = "Cannot disconnect your #{ type.capitalize } account. It is the only authorization you have with us."

          elsif @user.goals.active.where(checkin_with: type).size > 0
            flash.now[:alert] = "There are goals listening for check-ins from #{ type.capitalize }. You can disconnect after they are all completed."

          else
            Authorization.transaction do
              auth.destroy
              reminder.destroy if reminder.present?
            end
          end
        end
      elsif params[:user][:sms].present?
        if params[:user][:sms][0] != '+'
          @msg = "Your phone number should start with \"+\". Please include the country code."
        else
          @msg = "A text message is sent to #{ params[:user][:sms] }. Please use it to verify the phone number."
          
          @reminder = SmsReminder.create user: current_user, recipient: current_user.to_s, recipient_id: params[:user][:sms], verification_code: rand(1000..9999)
        end
        
        render 'sms'

      elsif params[:user][:sms_verify_code].present?
        @reminder = current_user.reminders.find_by(type: "SmsReminder")
        
        if @reminder.verification_code == params[:user][:sms_verify_code]
          @reminder.update_attribute :verified_at, Time.now
          
          @msg = "You've verified the phone number."
        else
          @msg = "The verification code does not match. Please check and try again."
        end
          
        render 'sms_verified'
        
      elsif params[:user][:remind_at].present?
        @reminder = current_user.reminders.find_by(type: "SmsReminder")
        
        respond_to do |format|
          if @reminder.update(remind_at: params[:user][:remind_at])
            format.js { head :no_content }
          else
            format.js { head :unprocessable_entity }
          end
        end
      
      elsif params[:user][:reminder].present? # updaing reminder settings
        reminder_params = params[:user][:reminder]
        type = reminder_params[:change]

        succeed = true

        if %w(twitter email sms).include?(type)
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
  def set_current_user
    @user = current_user
  end

  def user_params
    accessible = [ :display_name, :username, :email, :timezone, :slug, :avatar, :remote_avatar_url ] # extend with your own params
    params.require(:user).permit(accessible)
  end

  def ensure_signup_complete
    # Ensure we don't go into an infinite loop
    return if action_name == 'finish_signup'

    # Redirect to the 'finish_signup' page if the user
    # email hasn't been verified yet
    if current_user && !current_user.email_valid?
      redirect_to finish_signup_path
    end
  end
end
