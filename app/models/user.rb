class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :validatable, :recoverable, :rememberable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :email, presence: true
  validates :username, presence: true, uniqueness: true

  has_many :members, dependent: :destroy
  has_many :categories, dependent: :destroy

  after_create :create_member

  scope :search, ->(query) { query.present? ? where("username ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%") : none }

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.now.utc
    save!
   end
   
   def password_token_valid?
    (self.reset_password_sent_at + 4.hours) > Time.now.utc
   end
   
   def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save!
   end
   
   private
   
   def generate_token
    SecureRandom.hex(10)
   end

  def create_member
    self.members.create(username: self.username, kind: 'admin')
    self.member_id = self.members.first.id
    self.save
  end
end
