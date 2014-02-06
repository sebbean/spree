module Spree
  module Api
    class StockReturnsController < Spree::Api::BaseController
      before_filter :load_order

      def create
        authorize! :create, StockReturn
        @stock_return = @order.stock_returns.build(params[:stock_return])
        @stock_return.save
        render "spree/api/stock_returns/show"
      end
      
      private

      def load_order
        @order = Spree::Order.find_by(number: params[:order_id])
      end
    end
  end
end