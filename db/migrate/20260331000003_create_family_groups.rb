class CreateFamilyGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :family_groups do |t|
      t.string :name, null: false
      t.bigint :owner_id

      t.timestamps
    end

    add_index :family_groups, :owner_id
    add_foreign_key :family_groups, :accounts, column: :owner_id
  end
end
