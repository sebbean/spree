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
      if confirm(Spree.translations.are_you_sure_delete)
        object = this.get('model')
        object.set('quantity', 0)
        object.update()