class Deposit < ActiveRecord::Base
  belongs_to :goal
  belongs_to :user
  
  has_one :notification, class: Notification, as: :notifyable
  
  States = {
    10  => 'completed', #Deposit refunded
    5   => 'refund', #Waiting to be refunded
    0   => 'paid', #Deposit paid
  }
  
  acts_as_stateable states: States
  
  monetize :amount_cents
  
  after_commit :activate_goal, on: :create, :if => Proc.new { |d| d.goal.inactive? }
  
  after_commit :start_refund, on: :update, :if => Proc.new { |d| d.previous_changes['state'] = [0, 5] && d.refund? }
  
  after_commit :refund_completed, on: :update, :if => Proc.new { |d| d.previous_changes['state'] = [5, 10] && d.completed? }
  
  private
  def activate_goal
    self.goal.active!
  end
  
  def start_refund
    self.create_notification user: self.user, event: 'start-refund'
  end
  
  def refund_completed
    
  end
end
