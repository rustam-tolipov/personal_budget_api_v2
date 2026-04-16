class Budget < ApplicationRecord
  belongs_to :family_group, optional: true
  belongs_to :account, optional: true

  has_many :transactions, dependent: :destroy

  enum budget_type: { personal: 0, family: 1, savings: 2, expense: 3 }

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :budget_type, presence: true
  validates :limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :end_date, comparison: { greater_than: :start_date }, if: -> { start_date.present? && end_date.present? }

  validate :must_belong_to_group_or_account

  private

  def must_belong_to_group_or_account
    if family_group_id.nil? && account_id.nil?
      errors.add(:base, "must belong to a family group or an account")
    end
  end
end
