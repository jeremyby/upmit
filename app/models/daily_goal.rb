class DailyGoal < Goal
  def get_schedule(now)
    start_time = (now.in_time_zone(self.timezone) + self.starts.day).beginning_of_day
    schedule = IceCube::Schedule.new(start_time)
    end_time = start_time + (self.duration - 1).days

    schedule.add_recurrence_rule IceCube::Rule.daily(self.interval.to_i).until(end_time)
    occurrence = schedule.all_occurrences.size
    
    return start_time, schedule, occurrence
  end
  
  
  def starts_in_words
    self.starts > 0 ? 'Tomorrow' : 'Today'
  end

  def describe_last_occur
    'describe_daily_last_occur'
  end
  
  def describe_today_occur
    'describe_daily_today_occur'
  end
  
  def describe_next_occur
    'describe_daily_next_occur'
  end
end