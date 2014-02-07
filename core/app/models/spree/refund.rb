module Spree
  class Refund < ActiveRecord::Base
    attr_accessor :variant_id, :quantity  

    belongs_to :stock_return, class_name: 'Spree::StockReturn'

    has_many :items, class_name: 'Spree::RefundItem'

    after_create :create_items

    private

    def create_items
      variant = Spree::Variant.find(variant_id)
      quantity.to_i.times do
        line_item = stock_return.order.find_line_item_by_variant(variant)
        items.create(:variant_id => variant_id, :price => line_item.price)
      end
    end
  end
end
