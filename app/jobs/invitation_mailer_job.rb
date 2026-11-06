class InvitationMailerJob < ApplicationJob
  queue_as :default
  retry_on Errno::ECONNREFUSED, Net::OpenTimeout, wait: :exponentially_longer, attempts: 5

  def perform(invitation_id)
    invitation = Invitation.find_by(id: invitation_id)
    return unless invitation

    return if invitation.sent_at

    InvitationMailer.invite(invitation).deliver_now
    invitation.update!(sent_at: Time.current)
  rescue Net::SMTPFatalError => e
    Rails.logger.error "Failed to deliver invitation #{invitation_id}: #{e.message}"
  end
end
