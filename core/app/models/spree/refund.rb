module Spree
  class Refund < ActiveRecord::Base
    belongs_to :stock_return, class_name: 'Spree::StockReturn'
    belongs_to :variant, class_name: 'Spree::Variant'

    has_many :items, class_name: 'Spree::RefundItem'

    before_create :create_items

    private

    def create_items
      variant = Spree::Variant.find(variant_id)
      quantity.to_i.times do
        line_item = stock_return.order.find_line_item_by_variant(variant)
        items.build(
          :variant_id => variant_id, 
          :price => line_item.price,
          :currency => line_item.currency
        )
      end
    end
  end
end
