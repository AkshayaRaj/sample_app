class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :passive_relationships, class_name: "Relationship",
                                  foreign_key: "followed_id",
                                  dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length:{maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length:{maximum: 255}, format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  has_secure_password
  validates :password, length:{minimum: 3},presence: true, allow_nil: true

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

  def downcase_email
    self.email=email.downcase
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

  def authenticated?(attribute,token)
    digest = send ("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self. reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Returns a user's status feed
  def feed
    following_ids_subselect = "SELECT followed_id FROM relationships
                              WHERE follower_id= :user_id"
    Micropost.where("user_id IN (#{following_ids_subselect}) OR user_id = :user_id",
                     user_id: id)
  end

  #follows a user
  def follow(other_user)
     active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
     active_relationships.find_by(followed_id: other_user.id).destroy!
  end

  #returns true if the current user is following the other user
  def following?(other_user)
    # !active_relationships.find_by(followed_id: other_user.id).nil?
    self.following.include?(other_user) # here , following is the array of users that the user is following

  end

  private

    def create_activation_digest
      self.activation_token=User.new_token
      self.activation_digest=User.digest(activation_token)
    end


end
