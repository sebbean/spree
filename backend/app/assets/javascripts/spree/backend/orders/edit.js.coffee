#= require spree/backend/line_items/show
#= require spree/backend/shipments/show
#= require spree/backend/line_items/show
#= require_tree ./states

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

    refresh: ->
      order = this
      $.ajax
        url: this.url()
      .done (order_attrs) ->
        order.set(order_attrs)

  Spree.Admin.OrderView = Backbone.View.extend
    el: '#order',
    initialize: ->
      this.current_state = this.model.get('state')
      this.model.on('change', this.render, this)

    events:
      "click #states span": "setActiveState"

    # Display only the current state's info
    setActiveState: (e) ->
      $('#order .state_info').hide()
      el = $(e.target)
      state = el.data('state').toLowerCase()
      this.current_state = state
      $("#order ##{state}_info").show()

      # Set active state in "progress bar"
      $('#states span').removeClass()
      $("##{state}_state").addClass("active")

    render: ->
      el = this.$el
      order = this.model
      el.empty()

      # Default to the current state
      # This can be changed by setActiveState
      # Do not use .set here because it will trigger the change event
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
          current_state: this.current_state
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
      this.$el.find("##{this.current_state}_info").show()

    states: ->
      # Slice is used because otherwise pop() would pop off states from checkout_steps
      states = this.model.get('checkout_steps').slice(0)
      states.pop()
      _.map states, (state) ->
        state.substring(0,1).toUpperCase() + state.substring(1)

  Spree.Admin.OrderStateViews.Payment = Backbone.View.extend({})
  Spree.Admin.OrderStateViews.Confirmation = Backbone.View.extend({})


  Spree.Admin.OrderRouter = Backbone.Router.extend
    routes:
      '': 'show'


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