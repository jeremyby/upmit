class Commit < ActiveRecord::Base
  belongs_to :goal
  belongs_to :user

  States = {
    1   => 'succeed',
    0   => 'active',
    -10 => 'failed'
  }

  acts_as_stateable states: States

  scope :past, -> { where("state <> 0") }
  
  
  mount_uploader :photo, CommitPhotoUploader
  
  acts_as_commentable
  
  has_one :goal_activity, class: GoalActivities, as: :activeable
  
  after_commit :after_update_processing, on: :update, :if => Proc.new { |c| c.previous_changes['state'] == [0, 1] || c.previous_changes['state'] == [0, -10] }
  
  #####################################################################################
  # 
  # Class Methods
  #
  # ###################################################################################
  def self.get_occurrence_of(goal)
    now = Time.now
    
    # occurrence(s) on today/this week in case of weektimes
    tz = goal.timezone
    today_time = goal.is_a?(WeektimeGoal) ? now.in_time_zone(tz).beginning_of_week(start_day = :sunday).utc : now.in_time_zone(tz).beginning_of_day.utc
    today = goal.commits.where(starts_at: today_time)
    
    last_limit = goal.is_a?(WeektimeGoal) ? goal.weektimes : 1
    last = goal.commits.where("starts_at < ?", today_time).limit(last_limit)
    
    next_occur = goal.commits.where("starts_at > ?", today_time).limit(1)
    
    return last, today, next_occur
  end


  def self.expired_commitments
    now = Time.now.utc
    
    # Daily commitments and weekly commitments with set weekdays
    # Weekly commitments with occurrences (week starts on Sunday for now)
    Commit.active.joins(:goal).where("(goals.type <> 'WeektimeGoal' AND commits.starts_at < ?)
                                    OR (goals.type = 'WeektimeGoal' AND commits.starts_at < ?)",
                                    now - 24.hours, now - now.wday.days - 7.days)
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
  
  
  private
  def after_update_processing
    self.goal.activities.create activeable_type: 'Commit', activeable_id: self.id
    
    if self == self.goal.commits.last # last_commit?
      self.goal.completed!
    end
  end
end
