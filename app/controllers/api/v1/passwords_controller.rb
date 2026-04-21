module Api
  module V1
    class PasswordsController < ApplicationController
      skip_before_action :authenticate_account!

      def forgot
        return render json: { error: 'Email not present' } if params[:email].blank?

        account = Account.find_by(email: params[:email])

        if account.present?
          account.generate_password_token!
          Devise::Mailer.reset_password_instructions(account, account.reset_password_token).deliver_later
          render json: { status: 'ok' }, status: :ok
        else
          render json: { error: ['Email address not found. Please check and try again.'] }, status: :not_found
        end
      end

      def reset
        token = params[:token].to_s

        return render json: { error: 'Token not present' } if params[:token].blank?

        account = Account.find_by(reset_password_token: token)

        if account.present? && account.password_token_valid?
          if account.reset_password!(params[:password])
            render json: { status: 'ok' }, status: :ok
          else
            render json: { error: account.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: ['Link not valid or expired. Try generating a new link.'] }, status: :not_found
        end
      end
    end
  end
end
