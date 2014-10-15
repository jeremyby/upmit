
TwitterConfig = YAML.load(File.read(Rails.root.join('config', 'twitter.yml')))[Rails.env]

UpmitTwitter = Twitter::REST::Client.new do |config|
  config.consumer_key        = TwitterConfig['api_key']
  config.consumer_secret     = TwitterConfig['api_secret']
  config.access_token        = TwitterConfig['access_token']
  config.access_token_secret = TwitterConfig['access_secret']
end