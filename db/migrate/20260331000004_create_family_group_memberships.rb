class CreateFamilyGroupMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :family_group_memberships do |t|
      t.references :family_group, null: false, foreign_key: true
      t.references :account,      null: false, foreign_key: true
      t.integer    :role,         null: false, default: 0

      t.timestamps
    end

    add_index :family_group_memberships, [:family_group_id, :account_id], unique: true, name: "index_fgm_on_family_group_and_account"
  end
end
