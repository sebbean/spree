module Spree
  class Refund < ActiveRecord::Base
    belongs_to :stock_return, class_name: 'Spree::StockReturn'
  end
end
