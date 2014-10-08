class Deposit < ActiveRecord::Base
  belongs_to :goal
  belongs_to :user
  
  States = {
    10  => 'completed', #Deposit refunded
    1   => 'paid', #Deposit paid
    0   => 'initial'
  }
  
  acts_as_stateable states: States
  
  monetize :amount_cents
  
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
