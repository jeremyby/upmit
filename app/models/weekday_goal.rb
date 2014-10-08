class WeekdayGoal < Goal
  def get_schedule(now)
    today = now.in_time_zone(self.timezone)
    
    start_time = (today - today.wday.days + (self.starts * 7).days).beginning_of_day
    schedule = IceCube::Schedule.new(start_time)
    end_time = start_time + (self.duration - 1).days

    schedule.add_recurrence_rule IceCube::Rule.weekly.day(self.weekdays.collect {|d| d.to_i}).until(end_time)

    occurrence = schedule.all_occurrences.size
    
    return start_time, schedule, occurrence
  end
  
  def describe_last_occur
    'describe_weekday_last_occur'
  end
  
  def describe_today_occur
    'describe_daily_today_occur'
  end
  
  def describe_next_occur
    'describe_weekday_next_occur'
  end
end