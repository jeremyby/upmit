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
  
  private
  def send_verification_code
    @client = Twilio::REST::Client.new
    
    @client.messages.create(from: '+18653095001', to: self.recipient_id, body: "#{ self.verification_code } is your verification code. Please use it to verify your phone number on Upmit.com.")
  end
end