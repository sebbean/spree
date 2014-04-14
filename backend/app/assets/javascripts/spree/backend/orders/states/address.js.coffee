#= require spree/backend/orders/states/base

Spree.Admin.OrderStateViews.Address = Spree.Admin.OrderStateViews.Base.extend
  tagName: 'form'
  className: 'state_info'
  id: 'address_info'
  events:
    "change #order_bill_address_attributes_country_id": "updateBillingStates"
    "change #order_ship_address_attributes_country_id": "updateShippingStates"
    "change #use_billing": "toggleShippingAddress"
    "change #guest_checkout": "toggleGuestCheckout"
    "change #order_user_id": "userSelected"
    "submit": "updateAddress"

  toggleShippingAddress: ->
    this.$el.find('#shipping_address').toggle()

  toggleGuestCheckout: ->
    this.$el.find('#guest_checkout_fields').toggle()
    this.$el.find('#user_picker').toggle()

  updateBillingStates: (e) ->
    this.updateStates(e, 'bill')

  updateShippingStates: (e) ->
    this.updateStates(e, 'ship')

  updateStates: (e, type) ->
    view = this
    e.preventDefault()
    country_id = $(e.target).val()
    $.ajax
      url: Spree.pathFor("api/countries/#{country_id}/states")
      success: (response) ->
        state_select = $("#order_#{type}_address_attributes_state_id")
        states = response.states
        if states.length > 0
          current_state_id = view.model.get("#{type}_address").state_id
          state_select.html(
            _.template($('#address_states_template').html(), {
              states: response.states,
              current_state_id: current_state_id 
            })
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
    ).done ->
      $.ajax(
        type: "PUT"
        url: order.url() + "/advance"
      ).done (response) ->
        order.set(response)

  userSelected: ->
    customer = this.customer
    model = this.model

    model.attributes['user_id'] = customer.id
    model.attributes['bill_address'] = customer.bill_address
    model.attributes['ship_address'] = customer.ship_address
    model.trigger('change')

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
    el.find('#order_email').val(order.get('email'))
    el.find('#order_user_id').val(order.get('user_id'))

    _.each ["bill", "ship"], (type) ->        
      view.fillAddressAttributes(type)
      view.buildCountrySelector(type)

    view.buildUserSelector()
    view.toggleUserInfo()

  fillAddressAttributes: (type) ->
    view = this
    _.each this.model.get("#{type}_address"), (value, key) ->
      view.$el.find("#order_#{type}_address_attributes_#{key}").val(value)

  buildUserSelector: ->
    view = this
    users_api = Spree.pathFor('api/users')
    customerTemplate = Handlebars.compile($('#customer_autocomplete_template').text())

    this.$el.find("#order_user_id").select2
      placeholder: Spree.translations.choose_a_customer
      initSelection: (element, callback) ->
        $.get users_api, { id_eq: element.val() }, (data) ->
          callback(data.users[0])
      ajax:
        url: users_api
        datatype: 'json'
        data: (term, page) ->
          q: 
            email_cont: term
        results: (data, page) ->
          results: data.users
      dropdownCssClass: 'customer_search'
      formatResult: (customer) ->
        customerTemplate
          customer: customer,
          bill_address: customer.bill_address,
          ship_address: customer.ship_address
      formatSelection: (customer) ->
        # HACK: To pass the customer and all associated data back to the change event
        view.customer = customer
        customer.email



  toggleUserInfo: ->
    if this.model.get('user_id')
      this.$el.find('#user_picker').show()
      this.$el.find('#guest_checkout_fields').hide()
      this.$el.find('#guest_checkout').prop('checked', '')
    else
      this.$el.find('#user_picker').hide()
      this.$el.find('#guest_checkout_fields').show()
      this.$el.find('#guest_checkout').prop('checked', 'checked')


  buildCountrySelector: (type) ->
    countries_api = Spree.pathFor('api/countries')
    country_id = this.$el.find("#order_#{type}_address_attributes_country_id")
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
