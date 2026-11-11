class CleanupExpiredInvitationsJob < ApplicationJob
  queue_as :default

  def perform
    expired_and_not_accepted = Invitation.where(expiration_date: ..Time.current, invitation_accepted: false)
    expired_and_not_accepted.delete_all
  end
end
