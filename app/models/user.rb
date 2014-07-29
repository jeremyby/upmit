class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  extend FriendlyId
  friendly_id :username_for_url, use: :slugged

  validates_presence_of :first_name, :last_name

  has_many :goals
  has_many :commits


  def normalize_friendly_id(string)
    s = string.to_ascii.parameterize

    if User.where("slug ~ ?", "^#{ s }$").count > 0
      offset = User.where("slug ~ ?", "^#{ s }-[\d]*").count + 1
      s << "-#{offset}"
    end
    
    return s
  end

  def username_for_url
    self.username.blank? ? "#{first_name} #{last_name}" : self.username
  end

  def name
    (self.first_name + ' ' + self.last_name).titlecase
  end

  alias_method :to_s, :name
end
