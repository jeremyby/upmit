class GoalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @active = current_user.goals.active
    @inactive = current_user.goals.inactive
    @completed = current_user.goals.completed.order('created_at asc')
  end

  def new
    @goal = Goal.new(interval_unit: 'day', duration: 100, interval: 1)
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
    @goal = current_user.goals.find_by_slug(params[:id])

    go_404 if @goal.blank?
  end
end
