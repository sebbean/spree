#= require spree/backend/orders/states/base

Spree.Admin.OrderStateViews.Address = Spree.Admin.OrderStateViews.Base.extend
  events:
    "change #order_bill_address_attributes_country_id": "updateBillingStates"
    "change #order_ship_address_attributes_country_id": "updateShippingStates"
    "change #use_billing": "toggleShippingAddress"
    "submit form": "updateAddress"

  toggleShippingAddress: ->
    $('#shipping_address').toggle()


  updateBillingStates: (e) ->
    this.updateStates(e, 'bill')

  updateShippingStates: (e) ->
    this.updateStates(e, 'ship')

  updateStates: (e, type) ->
    e.preventDefault()
    country_id = $(e.target).val()
    $.ajax
      url: Spree.pathFor("api/countries/#{country_id}/states")
      success: (response) ->
        state_select = $("#order_#{type}_address_attributes_state_id")
        states = response.states
        if states.length > 0
          state_select.html(
            _.template($('#address_states_template').html(), { states: response.states} )
          )
          state_select.select2()
          state_select.parent().show()

        else
          state_select.parent().hide()

  updateAddress: (e) ->
    e.preventDefault()
    data = $(e.target).serializeJSON()
    order = this.model
    if $('#use_billing').is(':checked')
      data.order.use_billing = true
      data.order.ship_address_attributes = data.order.bill_address_attributes

    # TODO: This probably belongs in the Order model
    $.ajax(
      type: "PUT"
      url: order.url()
      data: data
    ).done (response) ->
      order.set(response)


  render: ->
    view = this
    order = this.model
    el = this.$el
    template = _.template(
      $('#order_states_address_template').html(), {
        order: order,
        position: this.position
      }
    )
    el.append(template)
    _.each ["bill", "ship"], (type) ->        
      $('#order_email').val(order.get('email'))
      view.fillAddressAttributes(type)

      countries_api = Spree.pathFor('api/countries')
      country_id = el.find("#order_#{type}_address_attributes_country_id")
      country_id.select2
        initSelection: (element, callback) ->
          $.ajax
            url: countries_api + "/#{element.val()}"
          .done (response) ->
            callback(response)
        ajax:
          url: countries_api
          data: (term, page) ->
            q:
              name_cont: term
          results: (data, page) ->
            results: data["countries"]
        formatResult: (country) ->
          country.name
        formatSelection: (country) ->
          country.name

      # Loads + shows states select box if country_id has been pre-populated
      if country_id.val()
        country_id.trigger('change')

  fillAddressAttributes: (type) ->
    _.each this.model.get("#{type}_address"), (value, key) ->
      $("#order_#{type}_address_attributes_#{key}").val(value)
