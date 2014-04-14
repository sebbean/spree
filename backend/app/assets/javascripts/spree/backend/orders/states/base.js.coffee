Spree.Admin.OrderStateViews = {}
Spree.Admin.OrderStateViews.Base = Backbone.View.extend
  className: 'state_info no-border-bottom'
  tagName: 'fieldset'
  
  initialize: (options) ->
    this.position = options.position
