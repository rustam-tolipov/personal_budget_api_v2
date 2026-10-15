class InvitationMailerJob < ApplicationJob
  queue_as :default

  def perform(invitation_id)
    invitation = Invitation.find_by(id: invitation_id)
    return unless invitation

    InvitationMailer.invite(invitation).deliver_now
  end
end
