class WeekdayGoal < Goal
  def builder(offset, now, hash)
    self.attributes = hash.permit(:title, :duration, :interval, :interval_unit)
    self.weekdays = hash[:weekdays] #weekdays cannot be mass-assigned. for it's an array?

    today = now.in_time_zone(self.user.timezone)
    start_time = (today - today.wday.days + (offset * 7).days).beginning_of_day
    schedule = IceCube::Schedule.new(start_time)
    end_time = start_time + (self.duration - 1).days

    schedule.add_recurrence_rule IceCube::Rule.weekly.day(self.weekdays.collect {|d| d.to_i}).until(end_time)

    self.occurrence = schedule.all_occurrences.size
    
    return start_time, schedule
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