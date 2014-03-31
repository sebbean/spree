Backend.OrdersStatesAddressController = Ember.ObjectController.extend
  init: ->
    @set('guestCheckout', false)
  guestCheckout: (->
    !@get('user_id')
  ).property('guestCheckout')

  actions:
    toggleUserPicker: ->
      this.set('guestCheckout', !this.get('guestCheckout'))
    toggleUseBilling: ->
      this.set('useBilling', !this.get('useBilling'))

    update: ->
      params = {
        email: @get('email')
        bill_address_attributes: @get('bill_address.formParams')
        ship_address_attributes: @get('ship_address.formParams')
      }

      # TODO: Why does this have to be accessed through two content calls?
      # Shouldn't the model be accessible from this controller?
      model = @get('content.content')
      model.update(params)

       # if $('#use_billing').is(':checked')
       #   data.order.use_billing = true
       #   data.order.ship_address_attributes = data.order.bill_address_attributes