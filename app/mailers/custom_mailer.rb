class CustomMailer < ActionMailer::Base
  default from: "jeremy@upmit.com"

  def send_email(recipient)
    mail(to: recipient, subject: 'AWS account verification')
  end
end