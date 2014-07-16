class GoalsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @goals = current_user.goals
  end
  
  def new
    @goal = Goal.new(interval_unit: 'day')
  end
  
  def create
    @goal = current_user.goals.build(params[:goal].permit(:title, :timezone, :duration))
    
    offset = params[:goal][:starts] == '1' ? 1 : 0
    
    now = Time.now
    
    if params[:goal][:interval_unit] == 'week'
      start_time = now.in_time_zone(@goal.timezone).change(day: ((now.day - now.wday) + offset * 7)).beginning_of_day
      schedule = IceCube::Schedule.new(start_time)
      end_time = start_time + (@goal.duration - 1).days
      
      arr = params[:goal][:weekdays]
      
      if arr.blank? # weekly recurrence without setting weekdays
        # create schedule that simply recurs every week,
        # but need to set goal.weektimes
        schedule.add_recurrence_rule IceCube::Rule.weekly.until(end_time)
        @goal.weektimes = params[:goal][:weektimes].to_i
      else
        schedule.add_recurrence_rule IceCube::Rule.weekly.day(arr.collect {|a| a.to_i}).until(end_time)
      end
    else
      start_time = (now.in_time_zone(@goal.timezone) + offset.day).beginning_of_day
      schedule = IceCube::Schedule.new(start_time)
      end_time = start_time + (@goal.duration - 1).days
    
      schedule.add_recurrence_rule IceCube::Rule.daily(params[:goal][:interval].to_i).until(end_time)
    end
    
    @goal.occurrence = schedule.all_occurrences.size
    @goal.schedule_yaml = schedule.to_yaml
    @goal.state = 0
    
    if @goal.save
      redirect_to '/'
    else
      render :new
    end
  end
end
