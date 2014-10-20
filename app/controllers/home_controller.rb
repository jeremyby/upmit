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
  
  def help
  end
  
  def terms
  end
  
  def no_smoking
  end
  
  def start_jogging
  end
  
  def new_habit
  end
  
  def bad_habit
    
  end
end
