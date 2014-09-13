class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  extend FriendlyId
  friendly_id :username_for_url, use: :slugged

  validates_presence_of :first_name

  has_many :authorizations, dependent: :destroy

  has_many :goals
  has_many :commits
  has_many :reminders, dependent: :destroy
  
  after_create :create_email_reminder, if: Proc.new { |u| u.email_valid? }
  after_update :create_email_reminder, if: Proc.new { |u| u.previous_changes['email'].present? && u.previous_changes['email'][0] =~ TEMP_EMAIL_REGEX && u.email_valid? }
  
  attr_accessor :follow_upmit


  def normalize_friendly_id(string)
    s = string.to_ascii.parameterize

    if User.where("slug REGEXP ?", "^#{ s }$").count > 0
      offset = User.where("slug REGEXP ?", "^#{ s }-[\d]*").count + 1
      s << "-#{ offset }"
    end

    return s
  end

  def username_for_url
    self.username.blank? ? "#{first_name} #{last_name}" : self.username
  end
  
  

  #####################################################################################
  # 
  # Oauth
  #
  # ###################################################################################
  
  TEMP_EMAIL_PREFIX = 'need_to_change_me@'
  TEMP_EMAIL_REGEX = /\Aneed_to_change_me@/
  
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
      user = User.where(email: email).first if email.present?

      # Create the user if it's a new registration
      if user.nil?
        if auth.info.first_name.blank?
          arr = auth.info.name.split
          last_name = arr.pop
          first_name = arr.shift || auth.info.nickname
        else
          last_name = auth.info.last_name
          first_name = auth.info.first_name
        end
        
        user = User.new(
          first_name: first_name,
          last_name: last_name, 
          username: auth.info.name,
          email: email.present? ? email : "#{ TEMP_EMAIL_PREFIX }#{ authorization.provider }-#{ authorization.uid }.com",
          password: Devise.friendly_token[8,8]
        )

        user.save!
      end
    end

    # Associate the auth with the user if needed
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
    User.joins(:goals, :commits).where(
                                  "(goals.type <> 'WeektimeGoal' AND commits.starts_at < ? AND commits.starts_at >= ? AND commits.reminded < 0)
                                  OR (goals.type = 'WeektimeGoal' AND commits.starts_at < ? AND commits.starts_at >= ? AND commits.reminded <= 6)",
                                  now, now - 24.hours, 
                                  now, now - now.wday.days - 7.days
                                )
                                .where('commits.state = 0').group('users.id')
  end



  #####################################################################################
  # 
  # Callbacks
  #
  # ###################################################################################
  def create_email_reminder
    reminder = self.reminders.find_or_initialize_by(type: 'EmailReminder')
    reminder.attributes = { recipient: self.first_name, recipient_id: self.email }
    
    reminder.save!
  end


  #####################################################################################
  # 
  # Format & Outputs
  #
  # ###################################################################################
  def name
    (self.first_name + ' ' + self.last_name).titlecase
  end

  alias_method :to_s, :name
end
