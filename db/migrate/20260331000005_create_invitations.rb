class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :invitations do |t|
      t.references :family_group, null: false, foreign_key: true
      t.references :inviter,      null: false, foreign_key: { to_table: :accounts }
      t.string     :invitation_email,    null: false
      t.string     :token,               null: false
      t.datetime   :expiration_date,     null: false
      t.boolean    :invitation_accepted, null: false, default: false

      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, [:family_group_id, :invitation_email], unique: true, name: "index_invitations_on_group_and_email"
  end
end
