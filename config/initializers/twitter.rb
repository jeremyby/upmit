
twitter_config = YAML.load(File.read(Rails.root.join('config', 'twitter.yml')))[Rails.env]

UpmitMentionSince = MentionPointer.find_or_create_by(id: 1) if ActiveRecord::Base.connection.table_exists? 'upmit_dev.mention_pointers'

UpmitTwitter = Twitter::REST::Client.new do |config|
  config.consumer_key        = twitter_config['api_key']
  config.consumer_secret     = twitter_config['api_secret']
  config.access_token        = twitter_config['access_token']
  config.access_token_secret = twitter_config['access_secret']
end