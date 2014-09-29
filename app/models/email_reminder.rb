class EmailReminder < Reminder
  def deliver(items)
    if self.user.email_valid?
      text = "Today's reminder: #{ items.collect{|i| '#' + i[1]}.join(' ')}"
    
      RemindMailer.reminder_email(self, text).deliver
      
      return true
    else
      return false
    end
  end
end