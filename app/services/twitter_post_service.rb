class TwitterPostService
  def initialize(auth)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = TwitterConfig['api_key']
      config.consumer_secret     = TwitterConfig['api_secret']
      config.access_token        = auth.token
      config.access_token_secret = auth.secret
    end
  end
  
  def post(text)
    @client.update("#{ text } via https://upmit.com")
  end
end