class TwitterReminder < Reminder
  def deliver(items)
    string = "Today's reminder: #{ items.collect{|i| i[1]}.join(', ')} #upmit"
    
    UpmitTwitter.delay.dm(self.recipient_id.to_i, string)
  end
end