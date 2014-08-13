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
  

  def self.active_commitments
    now = Time.now.utc
    
    Commit.joins(:goal).includes(:goal)
                        .where(
                                '(goals.weektimes is NULL AND commits.state = 0 AND commits.starts_at < ? AND commits.starts_at >= ?)
                                OR (goals.weektimes is NOT NULL AND commits.state = 0 AND commits.starts_at < ? AND commits.starts_at >= ?)',
                                now, now - 48.hours, 
                                now, now - now.wday.days - 7.days
                              )
  end

  def self.get_occurrence_of(goal)
    now = Time.now
    time = goal.weektimes.blank? ? now - 1.day : now - now.wday.days - 1.day
    
    last = goal.commits.where(starts_at: goal.schedule.previous_occurrence(time).utc)
    today = goal.commits.where(starts_at: goal.schedule.previous_occurrence(now).utc)
    next_occur = goal.commits.where(starts_at: goal.schedule.next_occurrence(now).utc)
    
    return last, today, next_occur
  end


  def self.expired_commitments
    now = Time.now.utc
    
    # Daily commitments and weekly commitments with set weekdays
    # Weekly commitments with occurrences
    Commit.joins(:goal).where('(goals.weektimes is NULL AND commits.state = 0 AND commits.starts_at < ?)
                              OR (goals.weektimes is NOT NULL AND commits.state = 0 AND commits.starts_at < ?)',
                              now - 48.hours, now - now.wday.days - 7.days)
  end
  
  def late?
    now = Time.now.utc
    g = self.goal
    
    (g.weektimes.blank? && self.starts_at < now - 1.day) || (g.weektimes.present? && self.starts_at < now - 7.day)
  end
end
