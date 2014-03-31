Backend.OrdersLineItemsShowController = Ember.ObjectController.extend
  variant: (->
    @get('order').variantByID(this.get('variant_id'))
  ).property('variant')

  image: (->
    @get('variant').images[0].mini_url
  ).property('image')

  canUpdate: (->
    @get('order.permissions.can_update')
  ).property('canUpdate')

  
  actions:
    edit: ->
      this.set('editing', true)
    save: ->
      this.set('editing', false)
      this.get('model').update()
    cancel: ->
      this.set('editing', false)
    delete: ->
      variant_id = this.get('model.variant_id')
      original_quantity = this.get('model.original_quantity')
      if confirm(Spree.translations.are_you_sure_delete)
        this.get('shipment').adjustItems(variant_id, 0, original_quantity)