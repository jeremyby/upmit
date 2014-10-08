class Authorization < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
  
  # new authorization will always need to update for user
  after_commit :create_reminder, if: Proc.new { |a| a.provider == 'twitter' }
  
  def self.find_with(auth)
    record = find_or_initialize_by(uid: auth.uid, provider: auth.provider)
    
    if record.new_record?
      record.attributes = { username: auth.info.nickname || auth.info.name, token: auth.credentials.token, secret: auth.credentials.secret, link: auth.info.urls[auth.provider.capitalize]}
    end
    
    return record
  end
  
  private
  def create_reminder
    reminder = self.user.reminders.find_or_initialize_by(type: "#{ self.provider.capitalize }Reminder")
    
    reminder.attributes = { recipient: self.user.to_s, recipient_id: self.uid }
    
    reminder.save!
  end
end
