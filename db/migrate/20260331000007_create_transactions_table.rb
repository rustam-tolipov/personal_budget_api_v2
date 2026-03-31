class CreateTransactionsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string     :name,             null: false
      t.decimal    :amount,           null: false, precision: 10, scale: 2
      t.integer    :transaction_type, null: false, default: 0
      t.references :budget,           null: true,  foreign_key: true
      t.references :account,          null: false, foreign_key: true

      t.timestamps
    end
  end
end
