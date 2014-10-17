# CDN/external file settings
case Rails.env
when 'production'
  Twilio.configure do |config|
    config.account_sid = 'AC4621f62dc2cb6419e415291b707fd52d'
    config.auth_token = '411e5c069964a83c0878bfc0bfa927f3'
  end
else
  Twilio.configure do |config|
    config.account_sid = 'ACe445568a926a7a0c8091424c4eabde7f'
    config.auth_token = 'a76925fe7f284ef955b71b9aaa67ee17'
  end
end