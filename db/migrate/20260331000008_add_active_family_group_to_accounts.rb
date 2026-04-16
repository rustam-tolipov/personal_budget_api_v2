class AddActiveFamilyGroupToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_reference :accounts, :active_family_group, null: true, foreign_key: { to_table: :family_groups }
  end
end
