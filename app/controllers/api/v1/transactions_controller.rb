module Api
  module V1
    class TransactionsController < ApplicationController
      def index
        @category = Category.find(params[:id])

        @transactions = @category.transactions.where(member_id: params[:member_id])

        render json: @transactions, each_serializer: TransactionSerializer, status: :ok
      end

      def recent_transactions
        @member = Member.find(params[:id])

        @transactions = @member.transactions.order(updated_at: :desc).limit(12).map do |t|
          {
            id: t.id,
            name: t.name,
            amount: t.amount,
            group: t.group,
          }
        end

        render json: JSON.dump(@transactions), status: :ok
      end

      def show
        @transaction = Transaction.find(params[:id])

        render json: @transaction, serializer: TransactionSerializer, status: :ok
      end

      def search
        @member = Member.find(params[:member_id])

        query = params[:query]

        @transactions = Transaction.search(query).where(member_id: @member.id)

        render json: @transactions, each_serializer: TransactionSerializer, status: :ok
      end

      def create
        @transaction = Transaction.new(transaction_params)
        @transaction.group = @transaction.category.kind

        ActiveRecord::Base.transaction do
          if @transaction.category.total_amounts.find_by(member_id: @transaction.member_id).nil?
            @transaction.category.total_amounts.create!(member_id: @transaction.member_id, amount: @transaction.amount, kind: @transaction.category.kind)
          else
            total_amount = @transaction.category.total_amounts.find_by(member_id: @transaction.member_id).amount + @transaction.amount
            @transaction.category.total_amounts.find_by(member_id: @transaction.member_id).update!(amount: total_amount)
          end

          @transaction.save!
        end

        render json: @transaction, serializer: TransactionSerializer, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      def update
        @transaction = Transaction.find(params[:id])

        ActiveRecord::Base.transaction do
          if @transaction.amount != transaction_params[:amount].to_f
            total_amount = @transaction.category.total_amounts.find_by(member_id: @transaction.member_id).amount - @transaction.amount + transaction_params[:amount].to_f
            @transaction.category.total_amounts.find_by(member_id: @transaction.member_id).update!(amount: total_amount)
          end

          @transaction.update!(transaction_params)
        end

        render json: @transaction, serializer: TransactionSerializer, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      def destroy
        @transaction = Transaction.find(params[:id])

        if @transaction.destroy
          render json: @transaction, serializer: TransactionSerializer, status: :ok
        else
          render json: { errors: @transaction.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def transaction_params
        params.require(:transaction).permit(:name, :group, :amount, :member_id, :category_id, :created_at)
      end
    end    
  end
end
