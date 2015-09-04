class User < ActiveRecord::Base
  attr_accessor :remember_token
  before_save {self.email=email.downcase}
  validates :name, presence: true, length:{maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length:{maximum: 255}, format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  has_secure_password
  validates :password, length:{minimum: 6},presence: true, allow_nil: true

  class << self
      def digest(string)
        cost=ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
      end

      def new_token()
        SecureRandom.urlsafe_base64
      end
  end

  def remember
    #remember_token is a random generated string
    self.remember_token=User.new_token
    # the hashed value of remember_token is stored as the remember_digest attribute in the user database
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest,nil)
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end


end
