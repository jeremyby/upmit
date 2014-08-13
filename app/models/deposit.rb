class Deposit < ActiveRecord::Base
  belongs_to :goal
  belongs_to :user
  
  STATES = {
    10  => 'completed', #Deposit refunded
    1   => 'paid' #Deposit paid
  }
  
  acts_as_stateable states: STATES
  
  after_commit :activate_goal, on: :create, :if => Proc.new { |d| d.goal.inactive? }
  
  after_commit :complete_goal, on: :update, :if => Proc.new { |d| d.completed? }
  
  private
  def activate_goal
    self.goal.active!
  end
  
  def complete_goal
    self.goal.completed!
  end
end
