class FamilyGroup < ApplicationRecord
  belongs_to :owner, class_name: 'Account', optional: true

  has_many :family_group_memberships, dependent: :destroy
  has_many :accounts, through: :family_group_memberships
  has_many :invitations, dependent: :destroy
  has_many :budgets, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }

  before_destroy :nullify_active_family_group

  private

  def nullify_active_family_group
    Account.where(active_family_group_id: id).update_all(active_family_group_id: nil)
  end
end
