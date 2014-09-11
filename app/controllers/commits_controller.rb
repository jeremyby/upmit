class CommitsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_variables
  
  def check
    @commit.succeed!
    
    render "update"
  end
  
  def fail
    @commit.failed!
    
    render "update"
  end
  
  private
  def load_variables
    @commit = current_user.commits.find(params[:commit_id])
    @type = params[:type]
    
    last, today, next_occur = Commit.get_occurrence_of(@commit.goal)
    
    if @type == 'today'
      @method_name = @commit.goal.describe_today_occur
      @occur = today
    else
      @method_name =  @commit.goal.describe_last_occur
      @occur = last
    end
  end
end
