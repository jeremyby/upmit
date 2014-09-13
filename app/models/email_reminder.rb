class EmailReminder < Reminder
  def deliver(items)
    text = "Today's reminder: #{ items.collect{|i| '#' + i[1]}.join(' ')}"
    
    RemindMailer.reminder_email(self, text).deliver
  end
end