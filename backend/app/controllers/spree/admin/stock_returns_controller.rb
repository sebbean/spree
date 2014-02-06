module Spree
  module Admin
    class StockReturnsController < Spree::Admin::BaseController

      before_filter :load_order

      def index
        @stock_returns = @order.stock_returns
      end

      def show
        @stock_return = @order.stock_returns.find(params[:id])
      end

      def new
        @stock_return = StockReturn.new
      end

      def create
        @stock_return = @order.stock_returns.build(params[:stock_return])
        @stock_return.save
        flash[:success] = Spree.t(:successfully_created, :resource => Spree.t(:stock_return))
        redirect_to admin_order_stock_returns_url(@order)
      end

      private

      def load_order
        @order = Spree::Order.find_by(number: params[:order_id])
      end

    end
  end
end