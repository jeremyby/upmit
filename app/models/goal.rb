class TitleValidator < ActiveModel::EachValidator
  # Should not have live goals with duplidated title
  def validate_each(record, attribute, value)
    cond = record.id.blank? ? '1 = 1' : "id <> #{ record.id }"
    
    unless Goal.where("? AND user_id = ? AND title = ?", cond, record.user_id, value).where('state >= -1').blank?
      record.errors[attribute] << 'You have another active or pending goal with the same title.'
    end
  end
end

class TagValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless Goal.where("id <> ? AND user_id = ? AND hash_tag = ?", record.id, record.user_id, value).where('state >= -1').blank?
      record.errors[attribute] << 'You have another live goal with the same hash tag.'
    end
  end
end


class Goal < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :user
  
  def normalize_friendly_id(string)
    s = string.to_ascii.parameterize
    
    # User can have goals with same title with non-live goals, such as do some goals again
    # so we need to append a number to it for friendly_id
    if Goal.where("user_id = ? and slug REGEXP ?", self.user_id, "^#{ s }$").count > 0
      offset = Goal.where("user_id = ? and slug REGEXP ?", self.user_id,  "^#{ s }-[\d]*").count + 1
      s << "-#{offset}"
    end
    
    return s
  end
  
  belongs_to :user
  has_one :deposit
  
  has_many :commits, dependent: :destroy
  has_many :activities, class_name: 'GoalActivities', dependent: :destroy
  
  validates :user_id, presence: true
  validates :title, presence: true, title: true
  validates :hash_tag, tag: true, unless: 'self.hash_tag.blank?'
  
  before_create :select_legend
  
  # Create the first commit when the state of the goal is updated
  # from 'inactive' to 'active', that is - deposit paid
  after_commit :made_deposit, on: :update, :if => Proc.new { |g| g.previous_changes['state'] == [0, 10] }
  
  
  # Completed, state from 'active' to 'completed'
  after_commit :process_deposit, on: :update, :if => Proc.new { |g| g.previous_changes['state'] == [10, -5] }
  
  
  # Completed, state from 'active' to 'cancelled'
  after_commit :after_cancelled, on: :update, :if => Proc.new { |g| g.previous_changes['state'] == [10, -10] }
  
  
  
  WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  
  States = {
    10  => 'active',
    0   => 'inactive',
    -1  => 'onhold',
    -5  => 'completed',
    -10 => 'cancelled'
  }
  
  Labels = {
    10  => 'primary',
    0   => 'danger',
    -1  => 'warning',
    -5  => 'success',
    -10 => 'default'
  }
  
  Privacy = {
    10  => 'Public',
    5   => 'Friends',
    1   => 'Private'
  }
  
  PrivacySelect = [
    { value: 10, text: 'Public'},
    { value: 5, text: 'Friends'},
    { value: 1, text: 'Private'}
  ]
  
  acts_as_stateable states: States
  
  acts_as_commentable
  
  scope :live, -> { where("state >= -1") }
  
  serialize :weekdays
  
  #####################################################################################
  # 
  # Flags & Conditions
  #
  # ###################################################################################
  
  def live?
    self.state >= -1
  end
  
  def deleteable?
    self.inactive? || (self.active? && (Time.now - self.deposit.created_at) < 3.days)
  end
  
  #####################################################################################
  # 
  # Class Methods
  #
  # ###################################################################################
  def self.samples
    [
      'run', 'work out', 'not smoke', 'eat less', 'try harder at work', 'not procrastinate', 'study a new language',
      'not drink'
    ]
  end
  
  def self.build_for(user, hash)
    @goal = if hash[:interval_unit] == 'week'
      if hash[:weekdays].blank?
        WeektimeGoal.new
      else
        WeekdayGoal.new
      end
    else
      DailyGoal.new
    end
    
    @goal.attributes = hash.permit(:title, :duration, :interval, :interval_unit, :weektimes, :privacy, :timezone, :starts, :duration_desc)
    @goal.weekdays = hash[:weekdays] if hash[:weekdays].present?
    
    @goal.user = user
    @goal.checkin_with = user.checkin_with
    
    start_time, schedule, occurrence = @goal.get_schedule(Time.now)
    @goal.occurrence = occurrence
    
    return @goal
  end

  
  #####################################################################################
  # 
  # Building & Creating
  #
  # ###################################################################################
  def schedule
    IceCube::Schedule.from_yaml(self.schedule_yaml)
  end
  
  def settle(now)
    time, schedule, occurrence = self.get_schedule(now)
    
    self.attributes = { start_time: time, schedule_yaml: schedule.to_yaml, occurrence: occurrence }
  end
  
  def get_hash_tag
    s = self.title.split(' ').first
    
    if Goal.where("user_id = ? AND hash_tag = ? AND state >= -1", self.user_id, s).count > 0
      offset = Goal.where("user_id = ? AND state >= -1 AND hash_tag REGEXP ?", self.user_id, "^#{ s }-[\d]*").count + 1
      
      s << "-#{offset}"
    end
    
    return s
  end
  
  def create_first_commit
    self.schedule.first(2).each do |o|
      self.commits.create! user: self.user, starts_at: o
    end
    
    self.delay.batch_create_all_commits
  end
  
  def batch_create_all_commits
    all = self.schedule.all_occurrences[2..(self.occurrence - 1)]
    
    all.each do |o|
      self.commits.create! user: self.user, starts_at: o
    end
  end
  
  #####################################################################################
  # 
  # Output & Format
  #
  # ###################################################################################
  def to_frequency
    str = ''
    
    if self.interval_unit == 'day'
      str << 'every'
      str << " #{ self.interval }" if self.interval.to_i > 1
      str << (self.interval.to_i > 1 ? ' days' : ' day')
    else
      if self.weekdays.present?
        str = 'every ' + self.weekdays.collect{|d| WEEKDAYS[d.to_i] }.to_sentence
      elsif self.weektimes.to_i > 1
        str = "#{ self.weektimes } times a week"
      else
        str = 'once every week'
      end
    end
     return str
  end
  
  def starts_in_words
    self.starts > 0 ? 'Next Week' : 'This Week'
  end
  
  def start_time_string
    self.start_time.strftime("%Y-%m-%d")
  end
  
  def to_s
    self.to_frequency + " " + self.duration_desc
  end
  
  
  #####################################################################################
  # 
  # Callbacks
  #
  # ###################################################################################
  private  
  def select_legend
    legend = ''
    
    LEGEND_MAP.each do |key, arr|
      arr.each do |a|
        legend = key if self.title.include?(a)
      end
      
      break unless legend.blank?
    end
    
    self.legend = legend.blank? ? 'default' : legend
  end
  
  def made_deposit
    self.settle(Time.now)
    self.hash_tag = self.get_hash_tag
    
    self.save!
    
    self.create_first_commit
  end
  
  def process_deposit
    self.deposit.refund!
  end
  
  def after_cancelled
    self.title = "Cancelled - #{ self.title }"
    self.slug = nil
    
    self.save!
    
    self.commits.destroy_all
  end
end
