Backend.Order = Ember.Object.extend({})

Backend.Order.reopenClass
  urlRoot: Spree.pathFor('api/orders')

  findAll: ->
    Em.$.ajax
      url: this.urlRoot
    .then (data) ->
      Ember.run () ->
        orders = Em.A();
        orders.pushObjects(data.orders)

  find: (number) ->
    Em.$.ajax
      url: "#{this.urlRoot}/#{number}"
    .then (data) ->
      Ember.run () ->
        Backend.Order.create(data)


Backend.Order.reopen

  init: ->
    order = this
    associations = {
      line_items: Backend.LineItem,
      bill_address: Backend.Address,
      ship_address: Backend.Address,
      shipments: Backend.Shipment,
      payments: Backend.Payment
    }

    for name, model of associations
      association = this.get(name)
      if association.constructor == Array
        result = $.map association, (item) ->
          item.order = order
          model.create(item)
      else
        item = association
        item.order = order
        result = model.create(item)

      this.set(name, result)

  url: (->
    this.constructor.urlRoot + "/" + this.get('number')
  ).property('url')

  variants: (->
    $.map @get('line_items'), (item) ->
      Backend.Variant.create(item.variant)
  ).property('variants')

  variantByID: (variant_id) ->
    this.get('variants').find (variant) ->
      variant.id == variant_id

  lineItemByVariantID: (variant_id) ->
    item = @get('line_items').find (line_item) ->
      line_item.variant.id == variant_id

  canUpdate: (->
    @get('permissions.can_update')
  ).property('canUpdate')

  update: (params) ->
    order = this
    $.ajax
      method: 'PUT'
      url: this.get('url')
      data: { order: params }
    .then (data) ->
      order.setProperties(data)
      order.init()

  refresh: ->
    order = this
    $.ajax
      method: 'GET'
      url: this.get('url')
    .then (data) ->
      order.setProperties(data)
      order.init()
      
  advance: ->
    order = this
    store = @store
    adapter = @store.adapterFor(@constructor)
    serializer = store.serializerFor('order')
    url = adapter.buildURL("checkout", this.id)

    $.ajax(
      url: "#{this.url}/advance"
      method: "PUT"
    ).then((data) ->
       payload = serializer.extract(store, Backend.Order, data, order.id, 'find')
       store.push('order', payload)
       return store.findById('order', order.id)
    )

  states: (->
    states = this.get('checkout_steps')
    states.unshift("cart")
    confirm_index = states.indexOf('confirm')
    if confirm_index > -1
      states.splice(confirm_index, 1)
    # Remove complete state
    unless this.get('completed_at')
      states.pop()
    states
  ).property('states')

