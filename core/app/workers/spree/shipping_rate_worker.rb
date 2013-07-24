module Spree
  class ShippingRateWorker
    include Sidekiq::Worker

    def perform(order_id)
      order = Spree::Order.find(order_id)
      order.shipments.destroy_all

      packages = Spree::Stock::Coordinator.new(self).packages
      packages.each do |package|
        order.shipments << package.to_shipment
      end
    end
  end
end

