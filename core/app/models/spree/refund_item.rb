module Spree
  class RefundItem < ActiveRecord::Base
    belongs_to :variant, class_name: 'Spree::Variant'

    def display_price
      Spree::Money.new(price, :currency => currency)
    end
  end
end
