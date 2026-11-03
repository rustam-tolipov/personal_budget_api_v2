ActionMailer::Base.delivery_method = :test

class InviteUser < InvitationMailerJob
  def perform(invitation_id)
    super

    raise 'fake crash'
  end
end

def send_invitation(invitation_email)
  account = Account.find_by(email: 'bob@test.com')
  family_group = FamilyGroup.where(owner: account)
  membership = account.family_group_memberships.find_by(family_group: family_group)
  invitation = membership.family_group.invitations.find_by(invitation_email: invitation_email)

  begin
    InviteUser.perform_now(invitation.id)
    puts 'SUCCESS'
  rescue StandardError => e
    puts e.message
    InvitationMailerJob.perform_now(invitation.id)
    puts 'RETRY'
  end
  puts ActionMailer::Base.deliveries.size
end

send_invitation('bobsfamily1@email.com')
