class CreateBudgets < ActiveRecord::Migration[7.0]
  def change
    create_table :budgets do |t|
      t.string     :name,        null: false
      t.integer    :budget_type, null: false, default: 0
      t.decimal    :limit,       precision: 10, scale: 2
      t.date       :start_date
      t.date       :end_date
      t.references :family_group, null: true, foreign_key: true
      t.references :account,      null: true, foreign_key: true

      t.timestamps
    end

    # At least one of family_group_id or account_id must be present
    add_check_constraint :budgets,
      "family_group_id IS NOT NULL OR account_id IS NOT NULL",
      name: "budget_must_belong_to_group_or_account"
  end
end
