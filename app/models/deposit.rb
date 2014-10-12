class Deposit < ActiveRecord::Base
  belongs_to :goal
  belongs_to :user
  
  has_one :notification, class: Notification, as: :notifyable
  
  States = {
    10  => 'completed', # deposit refunded
    5   => 'refund', # waiting to be refunded
    0   => 'paid', # deposit paid
    -1  => 'cancelled', # goal cancelled
  }
  
  PaypalAPI = PayPal::SDK::Merchant::API.new
  
  acts_as_stateable states: States
  
  monetize :amount_cents
  
  after_commit :activate_goal, on: :create, :if => Proc.new { |d| d.goal.inactive? }
  
  after_commit :start_refund, on: :update, :if => Proc.new { |d| d.previous_changes['state'] == [0, 5] && d.refund? }
  
  after_commit :goal_cancelled, on: :update, :if => Proc.new { |d| d.previous_changes['state'] == [0, -1] && d.cancelled? }
  
  after_commit :refund_completed, on: :update, :if => Proc.new { |d| d.previous_changes['state'] == [5, 10] && d.completed? }
  
  def retrieve_payer_email
    api = PayPal::SDK::Merchant::API.new
    
    detail = api.build_get_transaction_details({ TransactionID: self.transaction_id })
    
    response = api.get_transaction_details(detail)
    
    self.update payer: response.PaymentTransactionDetails.PayerInfo.Payer
  end
  
  
  def make_mass_pay(value)
    
    mass_pay = PaypalAPI.build_mass_pay({
      :ReceiverType => "EmailAddress",
      :MassPayItem => [{
        :ReceiverEmail => self.payer,
        :Amount => {
          :currencyID => "USD",
          :value => value } }] })
    
    return PaypalAPI.mass_pay(mass_pay)
  end
  
  
  def make_refund(value = self.amount)

    refund_transaction = PaypalAPI.build_refund_transaction({
      :TransactionID => self.transaction_id,
      :RefundType => self.amount > value ? 'Partial' : 'Full',
      :Amount => {
        :currencyID => "USD",
        :value => value },
      :RefundSource => "default" })
    
    return PaypalAPI.refund_transaction(refund_transaction)
  end

  
  private
  def activate_goal
    self.goal.active!
    
    self.delay.retrieve_payer_email
  end
  
  def start_refund
    self.create_notification user: self.user, event: 'start-refund'
  end
  
  
  def goal_cancelled
    
  end
  
  
  def refund_completed
    
  end
end
