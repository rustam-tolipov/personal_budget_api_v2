class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @group_name = invitation.family_group.name
    @inviter_name = invitation.inviter.username

    mail(to: invitation.invitation_email, subject: "You're invited to #{@group_name}")
  end
end
