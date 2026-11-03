class AddSentAtToInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :invitations, :sent_at, :datetime
  end
end
