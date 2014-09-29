class Authorization < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
  
  # new authorization will always need to update for user
  after_commit :create_reminder, on: :update, if: Proc.new { |a| a.previous_changes['user_id'].present? && a.user_id.present? }
  
  def self.find_with(auth)
    find_or_create_by(uid: auth.uid, username: auth.info.nickname,  provider: auth.provider, token: auth.credentials.token, secret: auth.credentials.secret)
  end
  
  private
  def create_reminder
    reminder = self.user.reminders.find_or_initialize_by(type: "#{ self.provider.capitalize }Reminder")
    
    reminder.attributes = { recipient: self.user.first_name, recipient_id: self.uid }
    
    reminder.save!
  end
end
