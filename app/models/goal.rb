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
  has_many :commits
  
  validates_presence_of :title, :timezone, :user_id
  
  WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  
  STATES = {
    10  => 'active',
    0   => 'pending',
    -1  => 'completed',
    -10 => 'cancelled'
  }
  
  acts_as_stateable states: STATES
  
  attr_accessor :starts
  
  serialize :weekdays
  
  def self.samples
    [
      'run', 'work out', 'not smoke', 'stay positive','try something new', 'stay on diet',
      'smile to a stranger', 'make real progress at work', 'not procrastinate'
    ]
  end
  
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
  
  def to_s
    self.to_frequency + " for #{ self.duration } days"
  end
  
  def schedule
    IceCube::Schedule.from_yaml(self.schedule_yaml)
  end
  
  def start_time_string
    self.start_time.strftime("%Y-%m-%d")
  end
  
  # Create the first commit when the state of the goal is updated
  # from 'pending' to 'active'
  after_commit :create_first_commit, on: :update, :if => Proc.new { |g| g.previous_changes['state'] == [0, 10] }
  
  def create_first_commit
    self.commits.create(starts_at: self.schedule.first)
  end
end
