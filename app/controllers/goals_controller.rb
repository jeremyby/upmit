class GoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_user_and_goal, only: [:show, :update, :destroy]
  before_action :current_owner, only: [:update, :destroy]

  def index
    begin
      @user = User.find_by_slug!(params[:user_id])
    rescue
      go_404
    end
  end

  def new
    @goal = Goal.new(interval_unit: 'day', duration: 21, interval: 1, duration_desc: 'for 21 days')
    
    if params[:title].present?
      @goal.title = params[:title]
    end 
  end

  def create
    @goal = Goal.build_for(current_user, params[:goal])
    
    # raise @goal.inspect

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
      if params[:goal][:hash_tag].present?
        params[:goal][:hash_tag].strip!
        params[:goal][:hash_tag].gsub!(/ /, '-')
      end
      
      if @goal.update_attributes(params[:goal].permit([:title, :description, :legend, :hash_tag, :privacy]))
        format.json { head :no_content } # 204 No Content
      else
        format.json { render json: @goal.errors.values[0][0], status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @goal.inactive?
      @goal.destroy!

      flash[:notice] = "Your goal \"#{ h @goal.title.titlecase }\" is deleted."
      redirect_to user_goals_path(current_user)
    elsif @goal.deleteable?
      response = @goal.deposit.make_refund
      
      if response.success?
        @goal.deposit.cancelled!
        @goal.cancelled!

        flash[:notice] = "Your goal \"#{ h @goal.title.titlecase }\" is cancelled."
        redirect_to user_goals_path(current_user)
      else
        @goal.errors.add(:deposit, "was not refunded. Please try again later." )
        
        flash[:alert] = response.Errors[0].LongMessage || @goal.errors.full_messages

        redirect_to user_goal_path(current_user, @goal)
      end
    else
      flash[:alert] = 'You cannot cancel this goal.'

      redirect_to user_goal_path(current_user, @goal)
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

  def current_owner
    unless current_user == @user
      return false
    end
  end
end
