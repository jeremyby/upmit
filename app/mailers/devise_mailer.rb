class DeviseMailer < Devise::Mailer

   def confirmation_instructions(record, token, opts={})
    super
    
    headers[:subject] = "Please confirm your email address on Upmit.com"
  end

end