class FollowUpmitService
  def initialize(auth)
    twitter_config = YAML.load(File.read(Rails.root.join('config', 'twitter.yml')))[Rails.env]

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = twitter_config['api_key']
      config.consumer_secret     = twitter_config['api_secret']
      config.access_token        = auth.token
      config.access_token_secret = auth.secret
    end
  end
  
  def follow
    @client.follow('upmit')
  end
end