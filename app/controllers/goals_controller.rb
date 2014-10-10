class GoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_user_and_goal, only: [:show, :update]

  def index
    begin
      @user = User.find_by_slug!(params[:user_id])
    rescue
      go_404
    end
  end

  def new
    @goal = Goal.new(interval_unit: 'day', duration: 100, interval: 1, duration_desc: 'for 100 days')
  end

  def create
    @goal = Goal.build_for(current_user, params[:goal])

    if @goal.save
      redirect_to new_goal_deposit_path(@goal)
    else
      render :new
    end
  end

  def show
    cond = '1 = 1'
    cond = ["id < ?", params[:since]] unless params[:since].blank?
    
    @limit = 10
    @limit = 25 if params[:limit].present?
    
    @activities = @goal.activities.includes(:activeable).order('id DESC').limit(@limit).where(cond)
    
    
    respond_to do |format|
      format.html
      format.js { render partial: 'activities' }
    end
  end

  def update
    respond_to do |format|
      if @goal.update_attributes(params[:goal].permit([:title, :description, :legend, :hash_tag, :privacy]))
        format.json { head :no_content } # 204 No Content
      else
        format.json { render json: @gaal.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def get_user_and_goal
    begin
      @user = User.find_by_slug!(params[:user_id])
      @goal = @user.goals.find_by_slug!(params[:id])
    rescue
      go_404
    end
  end
end
