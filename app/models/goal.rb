class Goal < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  def normalize_friendly_id(string)
    s = string.to_ascii.parameterize
    
    if Goal.where("user_id = ? and slug ~ ?", self.user_id, "^#{ s }$").count > 0
      offset = Goal.where("user_id = ? and slug ~ ?", self.user_id,  "^#{ s }-[\d]*").count + 1
      s << "-#{offset}"
    end
    
    return s
  end
  
  belongs_to :user
  has_one :deposit
  has_many :commits, dependent: :destroy
  
  validates_presence_of :title, :user_id
  
  before_create :select_legend
  
  # Create the first commit when the state of the goal is updated
  # from 'inactive' to 'active'
  after_commit :create_first_commit, on: :update, :if => Proc.new { |g| g.previous_changes['state'] == [0, 10] }
  
  WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  
  STATES = {
    10  => 'active',
    0   => 'inactive',
    -1  => 'completed',
    -5  => 'onhold',
    -10 => 'cancelled'
  }
  
  acts_as_stateable states: STATES
  
  attr_accessor :starts
  
  serialize :weekdays
  
  #####################################################################################
  # 
  # Class Methods
  #
  # ###################################################################################
  def self.samples
    [
      'run', 'work out', 'not smoke', 'stay positive','try something new', 'stay on diet',
      'smile to a stranger', 'make real progress at work', 'not procrastinate'
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
    
    @goal.user = user
    
    offset = hash[:starts] == '1' ? 1 : 0
    now = Time.now
    
    start_time, schedule = @goal.builder(offset, now, hash)
    
    @goal.start_time = start_time #giving value to goal will convert to UTC, therefore needing the temp start_time
    @goal.schedule_yaml = schedule.to_yaml
    
    return @goal
  end
  
  
  def self.remindable_for(user)
    now = Time.now
    
    user.goals.joins(:commits)
              .where("commits.state = 0 AND commits.reminded_at is NULL")
              .where("(goals.type <> 'WeektimeGoal' AND commits.starts_at = ?) OR (goals.type = 'WeektimeGoal' AND commits.starts_at = ?)",
                now.in_time_zone(user.timezone).beginning_of_day.utc, (now - now.wday.days).in_time_zone(user.timezone).beginning_of_day.utc)
    
  end

  
  #####################################################################################
  # 
  # Building & Creating
  #
  # ###################################################################################
  def schedule
    IceCube::Schedule.from_yaml(self.schedule_yaml)
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
  
  def start_time_string
    self.start_time.strftime("%Y-%m-%d")
  end
  
  def to_s
    self.to_frequency + " for #{ self.duration } days"
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
  
  def create_first_commit
    # Create the first commitment in real time
    # while leave the rest to delayed job
    self.commits.create! user: self.user, starts_at: self.schedule.first 
    
    self.delay.batch_create_all_commits
  end
  
  def batch_create_all_commits
    all = self.schedule.all_occurrences[1..(self.occurrence - 1)]
    
    all.each do |o|
      self.commits.create! user: self.user, starts_at: o
    end
  end
end
