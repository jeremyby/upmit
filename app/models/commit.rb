class Commit < ActiveRecord::Base
  belongs_to :goal
  belongs_to :user

  STATES = {
    1   => 'succeed',
    0   => 'active',
    -1  => 'failed'
  }

  acts_as_stateable states: STATES

  scope :past, -> { where("state <> 0") }
  
  #####################################################################################
  # 
  # Class Methods
  #
  # ###################################################################################
  def self.get_occurrence_of(goal)
    now = Time.now
    
    last_time = goal.weektimes.blank? ? now - 1.day : now - now.wday.days - 1.day
    today_time = goal.weektimes.blank? ? now.in_time_zone(goal.timezone).beginning_of_day.utc : (now - now.wday.days).in_time_zone(goal.timezone).beginning_of_day.utc
    
    # find the previous occurrence(s), therefore needs to access schedule
    last_occur = goal.schedule.previous_occurrence(last_time)
    last = goal.commits.where(starts_at: last_occur.utc) unless last_occur.blank? # the first occurrence
    
    # occurrence(s) on today/this week in case of weektimes
    today = goal.commits.where(starts_at: today_time)
    
    next_occur = goal.commits.where(starts_at: goal.schedule.next_occurrence(now).utc) unless goal.schedule.next_occurrence(now).blank? # the last occurrence
    
    return last, today, next_occur
  end


  def self.expired_commitments
    now = Time.now.utc
    
    # Daily commitments and weekly commitments with set weekdays
    # Weekly commitments with occurrences
    Commit.joins(:goal).where('(goals.weektimes is NULL AND commits.state = 0 AND commits.starts_at < ?)
                              OR (goals.weektimes is NOT NULL AND commits.state = 0 AND commits.starts_at < ?)',
                              now - 48.hours, now - now.wday.days - 8.days)
  end
  
  #####################################################################################
  # 
  # Logic
  #
  # ###################################################################################
  def late?
    now = Time.now.utc
    g = self.goal
    
    (g.weektimes.blank? && self.starts_at < now - 1.day) || (g.weektimes.present? && self.starts_at < now - 7.day)
  end
end
