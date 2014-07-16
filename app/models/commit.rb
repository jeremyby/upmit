class Commit < ActiveRecord::Base
  belongs_to :goal
  
  STATES = {
    1   => 'succeed',
    0   => 'pending',
    -1  => 'failed'
  }
  
  acts_as_stateable states: STATES
  
  # When state is pending and passed starts_at time
  scope :active, -> { where("state = 0 AND starts_at <= ?", Time.now.utc) }
  scope :past, -> { where("state <> 0 AND starts_at <= ?", Time.now.utc) }
  scope :failed, -> { where("state = -1 AND starts_at <= ?", Time.now.utc) }
  scope :succeed, -> { where("state = 1 AND starts_at <= ?", Time.now.utc) }
end
