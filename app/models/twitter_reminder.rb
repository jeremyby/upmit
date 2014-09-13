class TwitterReminder < Reminder
  def deliver(items)
    text = "@upmit today's reminder: #{ items.collect{|i| '#' + i[1]}.join(' ')}"
    
    UpmitTwitter.delay.dm(self.recipient_id.to_i, text)
  end
end