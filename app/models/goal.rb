class Goal < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :scoped, scope: :user
  
  def slug_candidates
    [
      :title,
      [:title, :start_time_string]
    ]
  end
  
  belongs_to :user
  has_many :commits
  
  validates_presence_of :title, :timezone, :user_id
  
  STATES = {
    10  => 'active',
    0   => 'pending',
    -1  => 'completed',
    -10 => 'cancelled'
  }
  
  attr_accessor :interval, :interval_unit, :weekdays, :starts
  
  acts_as_stateable states: STATES
  
  def self.samples
    [
      'run', 'work out', 'not smoke', 'stay positive','try something new', 'stay on diet',
      'smile to a stranger', 'make real progress at work', 'not procrastinate'
    ]
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
