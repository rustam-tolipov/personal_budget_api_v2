class Account < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # TODO: re-enable :confirmable once mailer is configured

  belongs_to :active_family_group, class_name: 'FamilyGroup', optional: true

  has_many :family_group_memberships, dependent: :destroy
  has_many :family_groups, through: :family_group_memberships
  has_many :owned_family_groups, class_name: 'FamilyGroup', foreign_key: :owner_id, dependent: :nullify
  has_many :sent_invitations, class_name: 'Invitation', foreign_key: :inviter_id, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3 }
  validates :email, presence: true

  scope :search, ->(query) {
    query.present? ? where("username ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?",
      "%#{query}%", "%#{query}%", "%#{query}%") : none
  }

  private

  def generate_password_token!
    self.reset_password_token = SecureRandom.hex(10)
    self.reset_password_sent_at = Time.now.utc
    save!
  end

  def password_token_valid?
    (reset_password_sent_at + 4.hours) > Time.now.utc
  end

  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save!
  end
end
