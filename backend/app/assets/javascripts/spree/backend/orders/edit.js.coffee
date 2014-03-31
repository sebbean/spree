//= require underscore
//= require backbone

$ ->

  "use strict"
  $("[data-hook=\"add_product_name\"]").find(".variant_autocomplete").variantAutocomplete()

  Spree.Shipment = Backbone.Model.extend
    isReady: ->
      this.get('state') == 'ready'
    url: ->
      "/api/orders/#{this.get('order').get('number')}/shipments/#{this.get('number')}"

    findVariant: (id) ->
      variant = _.find this.get('order').variants(), (v) ->
        v.id == id
    imageForVariant: (id) ->
      this.findVariant(id).images[0].mini_url

    findLineItem: (variant_id) ->
      line_item = _.find this.get('order').get('line_items'), (li) ->
        li.variant_id == variant_id

    adjustItems: (variant_id, quantity) ->
      manifest_item = _.find this.get('manifest'), (item) ->
        item.variant_id == variant_id
      new_url = ""
      new_quantity = 0
      if manifest_item.quantity < quantity
        new_url = this.url() + "/add"
        new_quantity = (quantity - manifest_item.quantity)
      else if manifest_item.quantity > quantity
        new_url = this.url() + "/remove"
        new_quantity = (manifest_item.quantity - quantity)
      new_url += '.json'

      if new_quantity != 0
        shipment = this
        $.ajax(
          type: "PUT",
          url: Spree.url(new_url),
          data: { variant_id: variant_id, quantity: new_quantity }
        )
        this.get('order').advance()


  Spree.Admin.ShipmentShow = Backbone.View.extend
    className: "shipment"
    tagName: "div"
    render: ->
      template = _.template($("#shipment_template").html(), { shipment: this.model })
      this.$el.html(template)

    events:
      "click a.edit-item": "toggleItemEdit"
      "click a.save-item": "saveItem"

    toggleItemEdit: (e) ->
      link = $(e.target)
      link_parent = link.parent()
      link_row = link.parents('tr')

      link_parent.find('a.edit-item').toggle()
      link_parent.find('a.cancel-item').toggle()
      link_parent.find('a.split-item').toggle()
      link_parent.find('a.save-item').toggle()
      link_parent.find('a.delete-item').toggle()

      link_row.find('td.item-qty-show').toggle()
      link_row.find('td.item-qty-edit').toggle()

      false

    saveItem: (e) ->
      link = $(e.target)
      variant_id = link.data('variant-id')
      quantity = parseInt(link.parents('tr').find('input.line_item_quantity').val())

      this.toggleItemEdit(e)
      this.model.adjustItems(variant_id, quantity)

      false


  Spree.Order = Backbone.Model.extend
    urlRoot: Spree.routes.checkouts_api
    idAttribute: "number"
    # Used within a shipment to display images and other details about the variants
    variants: ->
      _.map this.get('line_items'), (line_item) ->
        line_item.variant

    advance: ->
      $.ajax
        type: "PUT",
        url: this.url() + "/advance"

  Spree.Admin.OrderForm = Backbone.View.extend
    initialize: ->
      this.model.on('change', this.render, this)

    el: '#order-form',
    render: ->
      el = this.$el
      order = this.model
      edit_order_template = _.template($("#edit_order_template").html(), { order: order })
      el.html(edit_order_template)
      _.each order.get('shipments'), (shipment_attrs) ->
        shipment_attrs.order = order
        shipment = new Spree.Shipment(shipment_attrs)
        shipment_view = new Spree.Admin.ShipmentShow({ model: shipment, id: "shipment_#{shipment.get('id')}" })
        el.find('.shipments').append(shipment_view.$el)
        shipment_view.render()


  Spree.Admin.OrderRouter = Backbone.Router.extend
    routes:
      '': 'show'

  router = new Spree.Admin.OrderRouter
  router.on 'route:show', ->
    order = new Spree.Order(number: order_number)
    order.fetch
      success: (order) ->
        orderForm = new Spree.Admin.OrderForm(model: order)
        orderForm.render()

  Backbone.history.start()