class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  extend FriendlyId
  friendly_id :username, use: :slugged

  validates_presence_of :first_name, :last_name

  has_many :goals


  def normalize_friendly_id(string)
    s = string.downcase.split.join('-')
    
    if User.where("slug REGEXP ?", "^#{ s }$").count > 0
      offset = User.where("slug REGEXP ?", "^#{ s }-[\d]*").count + 1
      s << "-#{offset}"
    end
    
    return s
  end

  def username
    "#{first_name} #{last_name}"
  end

  def name
    (self.first_name + ' ' + self.last_name).titlecase
  end

  alias_method :to_s, :name
end
