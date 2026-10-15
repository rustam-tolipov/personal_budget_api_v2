module Api
  module V1
    class InvitationsController < ApplicationController
      def create
        membership = current_account.family_group_memberships.find_by(family_group_id: params[:family_group_id])
        return render json: { errors: ['Family group not found'] }, status: :not_found unless membership
        return render json: { errors: ['Only admins can invite'] }, status: :forbidden unless membership.admin?

        invitation = membership.family_group.invitations.new(invitation_params.merge(inviter: current_account))

        if invitation.save
          InvitationMailerJob.perform_later(invitation.id)
          render json: invitation.as_json(only: %i[id family_group_id invitation_email expiration_date]),
                 status: :created
        else
          render json: { errors: invitation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def invitation_params
        params.require(:invitation).permit(:invitation_email)
      end
    end
  end
end
