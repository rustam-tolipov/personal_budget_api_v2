module Api
  module V1
    class AccountsController < ApplicationController
      before_action :set_account, only: [:update]

      def me
        render json: current_account, status: :ok
      end

      def update
        if @account.update(account_params)
          render json: @account, status: :ok
        else
          render json: { errors: @account.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_account
        @account = current_account
      end

      def account_params
        params.require(:account).permit(:username, :first_name, :last_name, :avatar)
      end
    end
  end
end
