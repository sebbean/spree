#= require spree/backend/line_items/show
#= require spree/backend/shipments/show

$ ->

  "use strict"

  Spree.Variant = Backbone.Model.extend
    urlRoot: Spree.routes.variants_api

  Spree.Order = Backbone.Model.extend
    urlRoot: Spree.routes.checkouts_api
    idAttribute: "number"
    # Used within a shipment to display images and other details about the variants
    variants: ->
      _.map this.get('line_items'), (line_item) ->
        line_item.variant

    advance: ->
      order = this
      $.ajax
        type: "PUT",
        url: this.url() + "/advance"
      .done (order_attrs) -> 
        order.set(order_attrs)

  Spree.Admin.OrderView = Backbone.View.extend
    el: '#order',
    initialize: ->
      this.model.on('change', this.render, this)

    events:
      "click #states span": "setActiveState"

    setActiveState: (e) ->
      # Display only the current state's info
      $('#order .state_info').hide()
      el = $(e.target)
      state = el.data('state').toLowerCase()
      $("#order ##{state}_info").show()

      # Set active state in "progress bar"
      $('#states span').removeClass()
      $("##{state}_state").addClass("active")

    states: ->
      states = this.model.get('checkout_steps')
      states.pop()
      _.map states, (state) ->
        state.substring(0,1).toUpperCase() + state.substring(1)

    render: ->
      el = this.$el
      order = this.model
      el.empty()

      this.renderStatesBar()
      this.renderStates()
      this.renderSidebar()

      order_totals_template = _.template($("#order_totals_template").html(), { order: order })
      el.append(order_totals_template)

      # Ensure that the tooltips display for all elements that should have them
      Spree.Admin.tipMe()

    renderSidebar: ->
      # This breaks with Backbone conventions, as it is touching an el outside this view's el
      # I think it's OK though because it's related info
      sidebar_template = _.template($('#order_sidebar_template').html(), { order: this.model })
      $('#order_information').html(sidebar_template)

    renderStatesBar: ->
      states = this.states()
      states.unshift("Cart")
      states_template = _.template(
        $('#order_states_template').html(), {
          states: states,
          current_state: this.model.get('state')
        })
      this.$el.prepend(states_template)

    renderStates: ->
      order = this.model
      # Render the cart
      cart_view = new Spree.Admin.OrderStateViews.Cart({ model: order, position: 1 })
      cart_view.render()

      # Render all the other states
      _.each this.states(), (state, index) ->
        console.log("Rendering state template: #{state}")
        state_view = new Spree.Admin.OrderStateViews[state]({ model: order, position: index+2 })
        state_view.render()

      this.$el.find(".state_info").hide()
      this.$el.find("##{order.get('state')}_info").show()


  Spree.Admin.OrderStateViews = {}
  Spree.Admin.OrderStateViews.Base = Backbone.View.extend
    initialize: (options) ->
      this.position = options.position

    el: '#order'

  Spree.Admin.OrderStateViews.Cart = Spree.Admin.OrderStateViews.Base.extend
    events:
      "change #add_variant_id": "showStockDetails"
      "click .add_variant": "addVariant"

    render: ->
      order = this.model
      template = _.template($('#order_states_cart_template').html(), { order: order, position: this.position })
      this.$el.append(template)
      this.renderLineItems()

      $('#add_variant_id').variantAutocomplete()

    renderLineItems: ->
      order = this.model
      line_items = order.get('line_items')
      line_items_table = this.$el.find('#cart_info .line-items')
      no_items_message = this.$el.find('#no-items-message')

      if line_items.length > 0
        no_items_message.hide()
        line_items_table.show()
        _.each line_items, (line_item_attrs) ->
          line_item_attrs.order = order
          line_item = new Spree.LineItem(line_item_attrs)
          line_item_view = new Spree.Admin.LineItemShow({ model: line_item, id: "line-item-#{line_item.id}"})
          line_items_table.find('tbody').append(line_item_view.$el)
          line_item_view.render()
      else
        no_items_message.show()
        line_items_table.hide()

    showStockDetails: (e) ->
      variant_id = $(e.target).val();
      variant = new Spree.Variant(id: variant_id)
      variant.fetch
        success: (variant) ->
          $('#stock_details').html(_.template($("#variant_autocomplete_stock_template").html(), {variant: variant}));
          $('#stock_details').data('variant_id', variant.id)
          $('#stock_details').show();

    addVariant: (e) ->
      button = $(e.target)
      $('#stock_details').hide()

      item_row = button.closest('tr')
      variant_id = $('#stock_details').data('variant_id')
      stock_location_id = item_row.data('stock-location-id')
      quantity = item_row.find(".quantity").val()
      order = this.model

      $.ajax
        type: "POST"
        url: this.model.url() + "/line_items.json"
        data:
          line_item:
            variant_id: variant_id
            quantity: quantity
      .done (msg) ->
        order.advance()
      .error (msg) ->
        console.error(msg)

  Spree.Admin.OrderStateViews.Address = Spree.Admin.OrderStateViews.Base.extend
    render: ->
      order = this.model
      template = _.template($('#order_states_address_template').html(), { order: order, position: this.position })
      this.$el.append(template)
      # this.$el.find("#billing-country_id").select2


  Spree.Admin.OrderStateViews.Delivery = Backbone.View.extend({})
  Spree.Admin.OrderStateViews.Payment = Backbone.View.extend({})
  Spree.Admin.OrderStateViews.Confirmation = Backbone.View.extend({})


  Spree.Admin.OrderCustomerView = Backbone.View.extend
    el: '#order'
    render: -> 
      customer_template = _.template($('#customer_details_template').html(), { order: order })
      this.$el.html(customer_template)

  Spree.Admin.OrderRouter = Backbone.Router.extend
    routes:
      '': 'show',
      'customer': 'customer'


  router = new Spree.Admin.OrderRouter

  router.on 'route:show', ->
    Spree.Admin.currentOrder.fetch
      success: (order) ->
        orderView = new Spree.Admin.OrderView(model: order)
        orderView.render()

  router.on 'route:customer', ->
    customerView = new Spree.Admin.OrderCustomerView(model: order)
    customerView.render()

  if order_number?
    Spree.Admin.currentOrder = new Spree.Order(number: order_number)
    Backbone.history.start()