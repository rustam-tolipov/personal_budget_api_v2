class FamilyGroupMembership < ApplicationRecord
  belongs_to :family_group
  belongs_to :account

  enum role: { member: 0, admin: 1 }

  validates :role, presence: true
  validates :account_id, uniqueness: { scope: :family_group_id, message: "is already a member of this group" }
end
