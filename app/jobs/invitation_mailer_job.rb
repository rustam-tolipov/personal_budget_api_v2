class InvitationMailerJob < ApplicationJob
  queue_as :default

  def perform(invitation_id)
    invitation = Invitation.find_by(id: invitation_id)
    return unless invitation

    return if invitation.sent_at

    InvitationMailer.invite(invitation).deliver_now
    invitation.update!(sent_at: Time.current)
  end
end
