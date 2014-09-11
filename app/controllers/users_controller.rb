class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :finish_signup]
  # before_action :ensure_signup_complete, only: [:new, :create, :update]

  def index

  end

  def show

  end

  # PATCH/PUT /users/:id.:format
  def update
    respond_to do |format|
      if @user.update(user_params)
        sign_in(@user == current_user ? @user : current_user, :bypass => true)
        format.html { redirect_to @user, notice: 'Your profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET/PATCH /users/:id/finish_signup
  def finish_signup
    if request.patch? && params[:user] #&& params[:user][:email]
      if @user.update(user_params)
        if params[:user][:follow_upmit]
          auth = @user.authorizations.where(provider: 'twitter').first
          
          follower = FollowUpmitService.new(auth) # Use a service to follow @upmit and delay it to avoid hold-up
          follower.delay.follow
        end
        
        sign_in(@user, :bypass => true)
        redirect_to root_path, notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    end
  end

  private
  def set_user
    @user = User.find_by_slug(params[:id])
  end

  def user_params
    accessible = [ :first_name, :last_name, :username, :email, :timezone ] # extend with your own params
    accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
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
