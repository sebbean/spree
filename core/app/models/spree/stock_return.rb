module Spree
  class StockReturn < ActiveRecord::Base

    belongs_to :order, class_name: 'Spree::Order'

  end
end
