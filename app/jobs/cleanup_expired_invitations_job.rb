class CleanupExpiredInvitationsJob < ApplicationJob
  queue_as :default

  def perform
    Invitation.expired.where(invitation_accepted: false).delete_all
  end
end
