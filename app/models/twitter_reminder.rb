class TwitterReminder < Reminder
  def deliver(items)
    text = "#{ Time.now.strftime('%b %d') } @upmit today's reminder: #{ items.collect{|i| '#' + i[1] }.join(' ') }"
    
    UpmitTwitter.delay.dm(self.recipient_id.to_i, text)
    
    return true
  end
end