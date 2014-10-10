class NotificationsController < ApplicationController
  before_action :authenticate_user!
  
  def read
    current_user.notifications.unread.update_all read: true
    
    respond_to do |format|
      format.js { head :no_content }
    end
  end
end
