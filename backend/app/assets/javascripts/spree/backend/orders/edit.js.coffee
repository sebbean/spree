#= require spree/backend/line_items/show
#= require spree/backend/shipments/show


Spree.Admin.OrderApp = angular.module('order', ['ngRoute'])

Spree.Admin.OrderApp.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.
    otherwise({
      controller: 'DetailsCtrl'
    })
]

Spree.Admin.OrderApp.controller 'DetailsCtrl', ['$scope', '$http', '$routeParams', '$location', ($scope, $http, $routeParams, $location) ->
  $ ->
  $http.get(Spree.Admin.apiPathFor("/checkouts/#{order_number}")).success (data) ->
    $scope.order = data
]

# $ ->

#   "use strict"


#   Spree.Variant = Backbone.Model.extend
#     urlRoot: Spree.routes.variants_api

#   Spree.Order = Backbone.Model.extend
#     urlRoot: Spree.routes.checkouts_api
#     idAttribute: "number"
#     # Used within a shipment to display images and other details about the variants
#     variants: ->
#       _.map this.get('line_items'), (line_item) ->
#         line_item.variant

#     advance: ->
#       order = this
#       $.ajax
#         type: "PUT",
#         url: this.url() + "/advance"
#       .done (order_attrs) -> 
#         order.set(order_attrs)

#   Spree.Admin.AddProductView = Backbone.View.extend
#     el: '#add-line-item'

#     events:
#       "change #add_variant_id": "showStockDetails"
#       "click .add_variant": "addVariant"

#     render: ->
#       # This element is static, but is contained within this view as we have some events we want triggered
#       # I'd rather not have this element rendered each time the order is rendered.
#       this.$el.find("#add_variant_id").variantAutocomplete()

#     showStockDetails: (e) ->
#       variant_id = $(e.target).val();
#       variant = new Spree.Variant(id: variant_id)
#       variant.fetch
#         success: (variant) ->
#           $('#stock_details').html(_.template($("#variant_autocomplete_stock_template").html(), {variant: variant}));
#           $('#stock_details').data('variant_id', variant.id)
#           $('#stock_details').show();

#     addVariant: (e) ->
#       button = $(e.target)
#       $('#stock_details').hide()

#       item_row = button.closest('tr')
#       variant_id = $('#stock_details').data('variant_id')
#       stock_location_id = item_row.data('stock-location-id')
#       quantity = item_row.find(".quantity").val()
#       order = this.model

#       $.ajax
#         type: "POST"
#         url: this.model.url() + "/line_items.json"
#         data:
#           line_item:
#             variant_id: variant_id
#             quantity: quantity
#       .done (msg) ->
#         order.advance()
#       .error (msg) ->
#         console.error(msg)

#   Spree.Admin.OrderView = Backbone.View.extend
#     initialize: ->
#       this.model.on('change', this.render, this)

#     el: '#order',

#     render: ->
#       el = this.$el
#       order = this.model
#       el.find(".spinner").hide()

#       edit_order_template = _.template($("#edit_order_template").html(), { order: order })
#       el.html(edit_order_template)

#       # I'd prefer if this was done with Backbone's collections, but I don't know how.
#       shipments = order.get('shipments')
#       if shipments.length > 0
#         _.each order.get('shipments'), (shipment_attrs) ->
#           shipment_attrs.order = order
#           shipment = new Spree.Shipment(shipment_attrs)
#           shipment_view = new Spree.Admin.ShipmentShow({ model: shipment, id: "shipment_#{shipment.id}" })
#           el.find('.shipments').append(shipment_view.$el)
#           shipment_view.render()
#       else
#         # There aren't any shipments, so render line items instead
#         # This may happen if the order is in a pre-delivery state, or if the order never goes through the delivery state
#         line_items = order.get('line_items')
#         if line_items.length > 0
#           $('.line-items').show()
#           _.each line_items, (line_item_attrs) ->
#             line_item_attrs.order = order
#             line_item = new Spree.LineItem(line_item_attrs)
#             line_item_view = new Spree.Admin.LineItemShow({ model: line_item, id: "line_item_#{line_item.id}"})
#             el.find('.line-items tbody').append(line_item_view.$el)
#             line_item_view.render()


#       # Ensure that the tooltips display for all elements that should have them
#       Spree.Admin.tipMe()
#       sidebar_template = _.template($('#order_sidebar_template').html(), { order: order })

#       # This breaks with Backbone conventions, as it is touching an el outside this view's el
#       # I think it's OK though because it's related info
#       $('#order_information').html(sidebar_template)


#   Spree.Admin.OrderCustomerView = Backbone.View.extend
#     el: '#order'
#     render: -> 
#       this.$el.html('Customer view goes here')

#   Spree.Admin.OrderRouter = Backbone.Router.extend
#     routes:
#       '': 'show',
#       'customer': 'customer'


#   router = new Spree.Admin.OrderRouter

#   router.on 'route:show', ->
#     Spree.Admin.currentOrder.fetch
#       success: (order) ->
#         addProductView = new Spree.Admin.AddProductView(model: order)
#         addProductView.render()
#         orderView = new Spree.Admin.OrderView(model: order)
#         orderView.render()

#   router.on 'route:customer', ->
#     customerView = new Spree.Admin.OrderCustomerView(model: order)
#     customerView.render()

#   if order_number?
#     Spree.Admin.currentOrder = new Spree.Order(number: order_number)
#     Backbone.history.start()