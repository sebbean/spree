module Spree
  class InventoryWorker
    include Sidekiq::Worker

    def perform(order_id, line_item_id, target_shipment_id)
      order = Spree::Order.find(order_id)
      line_item = order.line_items.with_deleted.find(line_item_id)
      shipment = order.shipments.find(target_shipment_id) if target_shipment_id
      Spree::OrderInventory.new(order).verify(line_item, shipment)
    end
  end
end