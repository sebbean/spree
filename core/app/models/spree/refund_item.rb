module Spree
  class RefundItem < ActiveRecord::Base
    belongs_to :variant, class_name: 'Spree::Variant'
  end
end
