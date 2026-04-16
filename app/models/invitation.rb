class Invitation < ApplicationRecord
  belongs_to :family_group
  belongs_to :inviter, class_name: 'Account'

  validates :invitation_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expiration_date, presence: true
  validates :invitation_email, uniqueness: { scope: :family_group_id, message: "has already been invited to this group" }

  before_validation :generate_token, on: :create
  before_validation :set_expiration_date, on: :create

  def accepted?
    invitation_accepted
  end

  def expired?
    expiration_date < Time.now.utc
  end

  def accept!
    update!(invitation_accepted: true)
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expiration_date
    self.expiration_date ||= 7.days.from_now
  end
end
