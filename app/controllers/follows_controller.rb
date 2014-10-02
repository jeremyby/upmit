class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_user
  
  def create
    current_user.follow(@user)
    
    render 'update'
  end
  
  def destroy
    current_user.stop_following(@user)
    
    render 'update'
  end
  
  private
  def get_user
    begin
      @user = User.find_by_slug!(params[:user_id])
    rescue
      go_404
    end
  end
end
