class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :budget, optional: true

  enum transaction_type: { debit: 0, credit: 1 }

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true

  validate :account_matches_budget_owner, if: -> { budget.present? }

  private

  def account_matches_budget_owner
    if budget.account_id.present? && budget.account_id != account_id
      errors.add(:account, "does not own this budget")
    end
  end
end
