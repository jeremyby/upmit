class HomeController < ApplicationController
  def index
    
    if user_signed_in?
      @goals = current_user.goals
      
      render 'main' and return 
    end
  end
end
