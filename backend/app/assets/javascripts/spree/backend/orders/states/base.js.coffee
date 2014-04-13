Spree.Admin.OrderStateViews = {}
Spree.Admin.OrderStateViews.Base = Backbone.View.extend
  initialize: (options) ->
    this.position = options.position

  el: '#order'
