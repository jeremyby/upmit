class HomeController < ApplicationController
  
  
  def index
    
    if user_signed_in?
      @active = current_user.goals.active.order('created_at desc')
      
      render 'main' and return 
    end
  end
  
  
  def confirmation_sent
  end
end
