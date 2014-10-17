class HomeController < ApplicationController
  def index
    if user_signed_in?
      render 'main' and return 
    end
  end
  
  
  def confirmation_sent
  end
  
  def privacy_policy
  end
  
  def about
  end
end
