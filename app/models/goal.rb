class Goal < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  def normalize_friendly_id(string)
    s = string.to_ascii.parameterize
    
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
  
  validates_presence_of :title, :user_id
  # validates :hash_tag, uniqueness: { scope: :user_id }
  
  before_create :select_legend
  
  # Create the first commit when the state of the goal is updated
  # from 'inactive' to 'active', that is - deposit paid
  after_commit :create_first_commit, on: :update, :if => Proc.new { |g| g.previous_changes['state'] == [0, 10] }
  
  WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  
  STATES = {
    10  => 'active',
    0   => 'inactive',
    -1  => 'completed',
    -5  => 'onhold',
    -10 => 'cancelled'
  }
  
  Labels = {
    10  => 'primary',
    0   => 'default',
    -1  => 'success',
    -5  => 'warning',
    -10 => 'danger'
  }
  
  acts_as_stateable states: STATES
  
  acts_as_commentable
  
  attr_accessor :starts
  
  serialize :weekdays
  
  #####################################################################################
  # 
  # Class Methods
  #
  # ###################################################################################
  def self.samples
    [
      'run', 'work out', 'not smoke', 'stay positive','try something new', 'have quality time with family', 'eat healthier',
      'smile to a stranger', 'try harder at work', 'not procrastinate', 'spend 30 minutes learning a new language', 'pray more'
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
    # Create the first 2 commitments in real time
    # while leave the rest to delayed job
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
end
