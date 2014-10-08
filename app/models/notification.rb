class Notification < ActiveRecord::Base
  belongs_to :user
  
  belongs_to :notifyable, :polymorphic => true
  
  scope :unread, -> { where(read: false) }
end
