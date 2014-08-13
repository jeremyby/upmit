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
    @goal = current_user.goals.build(params[:goal].permit(:title, :timezone, :duration, :interval, :interval_unit, :weektimes))
    @goal.weekdays = params[:goal][:weekdays] #weekdays cannot be mass-assigned. for it's an array?
    
    offset = params[:goal][:starts] == '1' ? 1 : 0
    
    now = Time.now
    
    if params[:goal][:interval_unit] == 'week'
      start_date = now.in_time_zone(@goal.timezone)
      start_time = (start_date - start_date.wday.days + (offset * 7).days).beginning_of_day
      schedule = IceCube::Schedule.new(start_time)
      end_time = start_time + (@goal.duration - 1).days
      
      if @goal.weekdays.blank? # weekly recurrence without setting weekdays
        # create schedule that simply recurs every week,
        # but need to set goal.weektimes
        schedule.add_recurrence_rule IceCube::Rule.weekly.until(end_time)
        
        @goal.occurrence = schedule.all_occurrences.size * @goal.weektimes.to_i
      else
        schedule.add_recurrence_rule IceCube::Rule.weekly.day(@goal.weekdays.collect {|d| d.to_i}).until(end_time)
        
        @goal.weektimes = nil #important! nully weektimes flag
        @goal.occurrence = schedule.all_occurrences.size
      end
    else
      start_time = (now.in_time_zone(@goal.timezone) + offset.day).beginning_of_day
      schedule = IceCube::Schedule.new(start_time)
      end_time = start_time + (@goal.duration - 1).days
    
      schedule.add_recurrence_rule IceCube::Rule.daily(@goal.interval.to_i).until(end_time)
      
      @goal.occurrence = schedule.all_occurrences.size
    end
    
    @goal.start_time = start_time #giving value to goal will convert to UTC, therefore needing the temp start_time
    @goal.schedule_yaml = schedule.to_yaml
    
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
