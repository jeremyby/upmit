class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def go_404
    render text: 'Not Found...', status: '404' and return
  end

  def go_500
    render text: 'Something went wrong...', status: '500' and return
  end
end
