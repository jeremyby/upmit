class FacebookPostService
  def initialize(auth)
    @graph = Koala::Facebook::API.new(auth.token)
  end
  
  def post(text)
    @graph.put_connections("me", "feed", :message => text)
  end
end