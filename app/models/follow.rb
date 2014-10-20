class Follow < ActiveRecord::Base
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, :polymorphic => true
  belongs_to :follower,   :polymorphic => true
  
  has_one :notification, class: Notification, as: :notifyable
  
  
  after_commit :notify, on: :create

  def block!
    self.update_attribute(:blocked, true)
  end
  
  private
  def notify
    self.create_notification user: self.followable, event: 'new-follower'
  end
end
