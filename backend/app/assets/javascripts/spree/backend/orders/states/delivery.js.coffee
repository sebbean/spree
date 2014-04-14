Spree.Admin.OrderStateViews.Delivery = Spree.Admin.OrderStateViews.Base.extend
  id: 'delivery_info'
  render: ->
    order = this.model
    template = _.template($('#order_states_delivery_template').html(), { order: order, position: this.position })
    this.$el.append(template)
    this.renderShipments()

  renderShipments: ->
    view = this
    order = this.model
    shipments = order.get('shipments')
    # no_items_message = this.$el.find('#no-items-message')

    if shipments.length > 0
      # no_items_message.hide()
      _.each shipments, (shipment_attrs) ->
        shipment_attrs.order = order
        shipment = new Spree.Shipment(shipment_attrs)
        shipment_view = new Spree.Admin.ShipmentShow({ model: shipment, id: "shipment-#{shipment.id}"})
        shipment_view.render()
        view.$el.append(shipment_view.$el)