module Api
  module V1
    class MembersController < ApplicationController
      def index
        @members = Member.includes(:categories).where(user_id: current_user.id).where.not(username: current_user.username).order(created_at: :desc).map do |m|
          {
            id: m.id,
            username: m.username,
            user_id: m.user_id,
            image: m.image,
            kind: m.kind,
          }
        end

        @first_member = current_user.members.first

        @members.unshift({
          id: @first_member.id,
          username: @first_member.username,
          user_id: @first_member.user_id,
          image: @first_member.image,
          kind: @first_member.kind,
        })

        render json: JSON.dump(@members), status: :ok
      end

      def settings_members
        @members = Member.includes(:categories).where(user_id: current_user.id).where.not(username: current_user.username).order(created_at: :desc).map do |m|
          {
            id: m.id,
            username: m.username,
            user_id: m.user_id,
            image: m.image,
            kind: m.kind,
            total_balance: m.total_balance,
          }
        end

        @first_member = current_user.members.first

        @members.unshift({
          id: @first_member.id,
          username: @first_member.username,
          user_id: @first_member.user_id,
          image: @first_member.image,
          kind: @first_member.kind,
          total_balance: @first_member.total_balance,
        })

        render json: JSON.dump(@members), status: :ok
      end

      def show
        @member = Member.find(params[:id])
        @categories = @member.categories
        render json: @categories, status: :ok
      end

      def create
        username = params[:username]
        user_id = current_user.id
        image = params[:image]

        @member = Member.new(username: username, user_id: user_id, image: image)

        if @member.save
          render json: @member, status: :created
        else
          render json: @member.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @member = Member.find(params[:id])

        if @member.username == current_user.username
          return render json: { error: 'Cannot delete your own member' }, status: :forbidden
        end

        @member.destroy
        render json: @member, status: :ok
      end

      def update
        username = params[:username]
        user_id = current_user.id
        image = params[:image]

        @member = Member.find(params[:id])

        if @member.update(username: username, user_id: user_id, image: image)
          render json: @member, status: :ok
        else
          render json: @member.errors, status: :unprocessable_entity
        end
      end
    
      private
    
      def member_params
        params.require(:member).permit(:username, :user_id, :image)
      end
    end    
  end
end