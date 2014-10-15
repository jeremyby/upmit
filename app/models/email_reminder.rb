class EmailReminder < Reminder
  def deliver(items)
    if self.user.email_valid?
      if items.size > 1
        text = "You have made commitments for these actions today: #{ items.collect{|i| '#' + i[1]}.join(' ')}."
      else
        text = "You have committed to the action today: #{ items.collect{|i| '#' + i[1]}.join(' ')}."
      end
    
      RemindMailer.reminder_email(self, text).deliver
      
      return true
    else
      return false
    end
  end
end