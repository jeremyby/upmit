class HomeController < ApplicationController
  def index
    
    if user_signed_in?
      @active = current_user.goals.active
      
      render 'main' and return 
    end
  end
end
