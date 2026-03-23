class TotalAmount < ApplicationRecord
  belongs_to :member
  belongs_to :category

  validates :kind, inclusion: { in: %w[income expense] }
  validates :amount, numericality: true
end
