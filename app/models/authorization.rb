class Authorization < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
  
  # new authorization will always need to update for user
  after_commit :create_reminder, on: :update
  
  def self.find_with(auth)
    find_or_create_by(uid: auth.uid, provider: auth.provider, token: auth.credentials.token, secret: auth.credentials.secret)
  end
  
  private
  def create_reminder
    self.user.reminders.create! recipient: self.user.first_name, recipient_id: self.uid, type: "#{ self.provider.capitalize }Reminder"
  end
end
