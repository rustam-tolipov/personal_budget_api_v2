module Api
  module V1
    class CategoriesController < ApplicationController

      def index        
        @member = Member.find(params[:member_id])
        @categories = @member.categories.order(created_at: :desc).map do |c|
          {
            id: c.id,
            name: c.name,
            icon: c.icon,
            kind: c.kind,
            user_id: c.user_id,
            total_amount: @member.total_amount(c.id)
          }
        end

        render json: JSON.dump(@categories), status: :ok
      end

      def show
        @category = Category.find(params[:id])

        render json: @category, serializer: CategorySerializer, status: :ok
      end

      def incomes
        @member = Member.find(params[:member_id])
        @categories = @member.categories.where(kind: "income").map do |c|
          {
            id: c.id,
            name: c.name,
            icon: c.icon,
            kind: c.kind,
            user_id: c.user_id,
            total_amount: @member.total_amount(c.id)
          }
        end

        render json: JSON.dump(@categories), status: :ok
      end

      def expenses
        @member = Member.find(params[:member_id])
        @categories = @member.categories.where(kind: "expense").map do |c|
          {
            id: c.id,
            name: c.name,
            icon: c.icon,
            kind: c.kind,
            user_id: c.user_id,
            total_amount: @member.total_amount(c.id)
          }
        end

        render json: JSON.dump(@categories), status: :ok
      end

      def create
        @user = current_user        
        
        @category = @user.categories.build(category_params)

        if params[:category][:members_ids].present?
          params[:category][:members_ids].each do |member_id|
            @category.members << Member.find(member_id)
          end
        end
        
        if @category.save
          render json: @category, status: :created
        else
          render json: @category.errors, status: :unprocessable_entity
        end
      end

      def update
        @category = Category.find(params[:id])

        if params[:category][:members_ids].present?
          @members_ids_to_add = params[:category][:members_ids].map(&:to_i) - @category.members_ids
          @members_ids_to_remove = @category.members_ids - params[:category][:members_ids].map(&:to_i)


          @members_ids_to_add.each do |member_id|
            @category.members << Member.find(member_id)
          end

          @members_ids_to_remove.each do |member_id|
            @category.members.delete(Member.find(member_id))
            @category.transactions.where(member_id: member_id).destroy_all
          end
        end

        if @category.update(category_params)

          render json: @category, status: :ok
        else
          render json: @category.errors, status: :unprocessable_entity
        end
      end

      def remove_from_member
        @category = Category.find(params[:category_id])
        @member = Member.find(params[:id])

        @category.members.delete(@member)

        render json: @category, status: :ok
      end

      def destroy
        @category = Category.find(params[:id])
        
        if @category.destroy
          render json: @category, status: :ok
        else
          render json: @category.errors, status: :unprocessable_entity
        end
      end

      private

      def category_params
        params.require(:category).permit(:name, :icon, :member_id, :kind, :members_ids => [])
      end
    end    
  end
end