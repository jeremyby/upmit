class CommitsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_commit
  before_action :load_variables, only: [:check, :fail]

  skip_before_filter :verify_authenticity_token, :only => :update

  def check
    @commit.update state: 1, checked_by: 'web', checked_at: Time.now
  end

  def fail
    @commit.update state: -10, checked_by: 'web', checked_at: Time.now

    render "check"
  end

  def update
    @commit.note = params[:note]

    if params[:photo].present?
      @commit.photo = params[:photo]
    elsif params[:remote_photo_url].present?
      @commit.remote_photo_url = params[:remote_photo_url]
    end
    
    unless @commit.save
      @error = 'There has been some problem. Please try again later.' 
    end
  end

  private
  def find_commit
    id = params[:commit_id] || params[:id]

    @commit = current_user.commits.find(id)
  end

  def load_variables
    last, today, next_occur = Commit.get_occurrence_of(@commit.goal)

    @occur = today
  end
end
