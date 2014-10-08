class WeektimeGoal < Goal
  def get_schedule(now)
    today = now.in_time_zone(self.timezone)
    start_time = (today - today.wday.days + (self.starts * 7).days).beginning_of_day
    schedule = IceCube::Schedule.new(start_time)
    end_time = start_time + (self.duration - 1).days

    # create schedule that simply recurs every week,
    # but need to multiple goal.occurrence
    schedule.add_recurrence_rule IceCube::Rule.weekly.until(end_time)
    
    occurrence = schedule.all_occurrences.size * self.weektimes.to_i
    
    return start_time, schedule, occurrence
  end
  
  def describe_last_occur
    'describe_weektime_last_occur'
  end
  
  def describe_today_occur
    'describe_weektime_today_occur'
  end
  
  def describe_next_occur
    'describe_weektime_next_occur'
  end
  
  def create_first_commit
    # override super's method
    self.schedule.first(2).each do |o|
      self.weektimes.times do
        self.commits.create! user: self.user, starts_at: o
      end
    end
    
    self.delay.batch_create_all_commits
  end
  
  def batch_create_all_commits
    # override super's method
    all = self.schedule.all_occurrences[2..(self.occurrence - 1)]
    
    all.each do |o|
      self.weektimes.times do
        self.commits.create! user: self.user, starts_at: o
      end
    end
  end
end