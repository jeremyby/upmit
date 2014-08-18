class CommitsController < ApplicationController
  before_action :authenticate_user!
  
  def check
    @commit = current_user.commits.find(params[:commit_id])
    
    type = params[:type]
    
    @commit.succeed!
    
    render "update_#{type}"
  end
  
  def fail
    @commit = current_user.commits.find(params[:commit_id])
    
    type = params[:type]
    
    @commit.failed!
    
    render "update_#{type}"
  end
end
