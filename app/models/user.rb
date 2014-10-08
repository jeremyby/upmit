class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  extend FriendlyId
  friendly_id :get_username, use: :slugged

  mount_uploader :avatar, AvatarUploader

  validates_presence_of :display_name
  validates :username, presence: true

  has_many :authorizations, dependent: :destroy

  has_many :goals
  has_many :deposits
  has_many :commits
  has_many :comments
  has_many :reminders, dependent: :destroy
  has_many :notifications, dependent: :destroy
  
  
  acts_as_followable
  acts_as_follower
  
  # create Email reminder after an email is confirmed
  after_commit :create_email_reminder_on_create, on: :create, if: Proc.new { |u| u.email_valid? }
  after_commit :create_email_reminder, on: :update, if: Proc.new { |u| u.previous_changes['confirmed_at'].present? && u.confirmed? }
  
  attr_accessor :follow_upmit, :current_password

  def normalize_friendly_id(string)
    s = string.to_ascii.parameterize

    if User.where("slug REGEXP ?", "^#{ s }$").count > 0
      offset = User.where("slug REGEXP ?", "^#{ s }-[\d]*").count + 1
      s << "-#{ offset }"
    end

    return s
  end
  

  #####################################################################################
  # 
  # Oauth
  #
  # ###################################################################################
  
  TEMP_EMAIL_PREFIX = 'please_change_me@'
  TEMP_EMAIL_REGEX = /\Aplease_change_me@/
  
  def self.find_for_oauth(auth, existing_user = nil)
    # Get the auth and user if they exist
    authorization = Authorization.find_with(auth)

    # If an existing_user is provided it always overrides the new user
    # to prevent the auth being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated auth) which
    # can be cleaned up at a later date.
    user = existing_user.blank? ? authorization.user : existing_user

    # Create the user if needed
    if user.nil?
      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      email_is_verified = auth.info.email.present? && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified
      
      user = User.find_by(email: email) if email.present?

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          display_name: auth.info.name, 
          username: auth.info.nickname || auth.info.name,
          email: email.present? ? email : "#{ TEMP_EMAIL_PREFIX }#{ authorization.provider }-#{ authorization.uid }.com",
          checkin_with: auth.provider,
          remote_avatar_url: auth.info.image
        )
        
        user.skip_confirmation!
        
        # Generate the slug here bacause validation will be skipped
        user.slug = user.normalize_friendly_id(user.username)
        
        user.save!(validate: false)
      end
    end

    # Associate the auth with the user if needed
    # The only case this is not needed is returning user signing in
    if authorization.user != user
      authorization.user = user
      authorization.save!
    end
    
    user
  end
  
  def email_valid?
    self.email.present? && self.email !~ TEMP_EMAIL_REGEX
  end
  
  #####################################################################################
  # 
  # Class methods
  #
  # ###################################################################################
  
  def self.remindables
    now = Time.now.utc
    
    # Non-weektime goals: active & not reminded
    # Weektime goals: active & not reminded 7 times, since we can't decide the weekday because of user timezone now
    User.joins(:goals, :commits).where("(goals.type <> 'WeektimeGoal' AND commits.reminded < 0)
                                      OR (goals.type = 'WeektimeGoal' AND commits.reminded <= 6)")
                                .where("commits.starts_at < ?", now)
                                .where('commits.state = 0').group('users.id')
  end



  #####################################################################################
  # 
  # Format & Outputs
  #
  # ###################################################################################  
  
  def to_s
    return self.display_name
  end
  


  #####################################################################################
  # 
  # Callbacks
  #
  # ###################################################################################

  def get_username
    self.username ||= self.display_name
    
    return self.username
  end
  
  def create_email_reminder_on_create
    self.create_email_reminder
  end
  
  def create_email_reminder
    reminder = self.reminders.find_or_initialize_by(type: 'EmailReminder')
    reminder.attributes = { recipient: self.to_s, recipient_id: self.email }
    
    reminder.save!
  end
end
