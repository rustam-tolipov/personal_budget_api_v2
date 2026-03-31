class DropLegacyTables < ActiveRecord::Migration[7.0]
  def up
    # Remove foreign keys before dropping tables to avoid constraint errors
    remove_foreign_key :categories, :members if foreign_key_exists?(:categories, :members)
    remove_foreign_key :categories, :users if foreign_key_exists?(:categories, :users)
    remove_foreign_key :members, :users if foreign_key_exists?(:members, :users)
    remove_foreign_key :total_amounts, :categories if foreign_key_exists?(:total_amounts, :categories)
    remove_foreign_key :total_amounts, :members if foreign_key_exists?(:total_amounts, :members)
    remove_foreign_key :transactions, :categories if foreign_key_exists?(:transactions, :categories)
    remove_foreign_key :transactions, :members if foreign_key_exists?(:transactions, :members)

    drop_table :categories_members, if_exists: true
    drop_table :total_amounts, if_exists: true
    drop_table :transactions, if_exists: true
    drop_table :categories, if_exists: true
    drop_table :members, if_exists: true
    drop_table :users, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Legacy tables cannot be restored. Check the legacy branch."
  end
end
