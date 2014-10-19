class SmsReminder < Reminder
  after_commit :send_verification_code, on: :create
  
  def remind_at_in_time
    if self.remind_at > 12
      "#{ self.remind_at.to_i } PM"
    else
      "#{ self.remind_at.to_i } AM"
    end
  end
  
  def deliver(items)
    text = "@upmit today's reminder: #{ items.collect{|i| '#' + i[1]}.join(' ')}"
    
    @client = Twilio::REST::Client.new
    
    @client.messages.create(from: '+18653095001', to: self.recipient_id, body: text)
    
    return true
  end
  
  def when_to_deliver
    diff = self.remind_at - Time.now.hour
    diff = 0 if diff < 0
    
    return diff.hours.from_now
  end
  
  handle_asynchronously :deliver, :run_at => Proc.new { |r| r.when_to_deliver }
  
  private
  def send_verification_code
    @client = Twilio::REST::Client.new
    
    @client.messages.create(from: '+18653095001', to: self.recipient_id, body: "#{ self.verification_code } is your verification code. Please use it to verify your phone number on Upmit.com.")
  end
end