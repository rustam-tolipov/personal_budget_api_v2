class Transaction < ApplicationRecord
  belongs_to :category
  belongs_to :member

  validates :name, :group, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }

  after_destroy :subtract_category_total_amount

  scope :search, -> (name) { name.present? ? where("name ILIKE ?", "%#{name}%") : none  }

  private

  def subtract_category_total_amount
    total_amount = self.category.total_amounts.find_by(member_id: self.member_id).amount - self.amount
    self.category.total_amounts.find_by(member_id: self.member_id).update(amount: total_amount)
  end
end
