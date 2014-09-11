class DailyGoal < Goal
  def builder(offset, now, hash)
    self.attributes = hash.permit(:title, :duration, :interval, :interval_unit)
  
    start_time = (now.in_time_zone(self.user.timezone) + offset.day).beginning_of_day
    schedule = IceCube::Schedule.new(start_time)
    end_time = start_time + (self.duration - 1).days

    schedule.add_recurrence_rule IceCube::Rule.daily(self.interval.to_i).until(end_time)
  
    self.occurrence = schedule.all_occurrences.size
    
    return start_time, schedule
  end


  def describe_last_occur
    'describe_daily_last_occur'
  end
  
  def describe_today_occur
    'describe_daily_today_occur'
  end
end