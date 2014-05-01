Backend.OrdersStatesAddressController = Ember.ObjectController.extend
  needs: ['order']

  init: ->
    @set('guestCheckout', false)
  guestCheckout: (->
    !@get('user_id')
  ).property('guestCheckout')
  hasUser: (->
    !@get('guestCheckout')
  ).property('hasUser').volatile()

  actions:
    toggleUseBilling: ->
      this.set('useBilling', !this.get('useBilling'))
    pickedCustomer: (customer) ->
      this.set('bill_address', Backend.Address.create(customer.bill_address))
      this.set('ship_address', Backend.Address.create(customer.ship_address))

    update: ->
      if this.get('hasUser')
        params = {
          user_id: @get('user_id')
        }
      else
        params = {
          email: @get('email')
        }

      params.bill_address_attributes = @get('bill_address.formParams')
      params.ship_address_attributes = @get('ship_address.formParams')

      this.get('controllers.order').update(params)

       # if $('#use_billing').is(':checked')
       #   data.order.use_billing = true
       #   data.order.ship_address_attributes = data.order.bill_address_attributes