class RemindMailer < ActionMailer::Base
  default from: "reminder@upmit.com"

  def reminder_email(reminder, text)
    @user = reminder.user
    @url  = 'https://upmit.com'
    @text = text
    
    mail(to: reminder.recipient_id, subject: "Today's Reminder from Upmit.com")
  end
end
