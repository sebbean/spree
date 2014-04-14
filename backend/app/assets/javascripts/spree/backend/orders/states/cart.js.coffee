#= require spree/backend/orders/states/base

Spree.Admin.OrderStateViews.Cart = Spree.Admin.OrderStateViews.Base.extend
  id: 'cart_info'
  events:
    "change #add_variant_id": "showStockDetails"
    "click .add_variant": "addVariant"

  render: ->
    order = this.model
    template = _.template($('#order_states_cart_template').html(), { order: order, position: this.position })
    this.$el.append(template)
    this.renderLineItems()

    this.$el.find('#add_variant_id').variantAutocomplete()

  renderLineItems: ->
    order = this.model
    line_items = order.get('line_items')
    line_items_table = this.$el.find('.line-items')
    no_items_message = this.$el.find('#no-items-message')

    if line_items.length > 0
      no_items_message.hide()
      line_items_table.show()
      _.each line_items, (line_item_attrs) ->
        line_item_attrs.order = order
        line_item = new Spree.LineItem(line_item_attrs)
        line_item_view = new Spree.Admin.LineItemShow({ model: line_item, id: "line-item-#{line_item.id}"})
        line_items_table.find('tbody').append(line_item_view.$el)
        line_item_view.render()
    else
      no_items_message.show()
      line_items_table.hide()

  showStockDetails: (e) ->
    variant_id = $(e.target).val();
    variant = new Spree.Variant(id: variant_id)
    variant.fetch
      success: (variant) ->
        $('#stock_details').html(_.template($("#variant_autocomplete_stock_template").html(), {variant: variant}));
        $('#stock_details').data('variant_id', variant.id)
        $('#stock_details').show();

  addVariant: (e) ->
    e.preventDefault()
    button = $(e.target)
    $('#stock_details').hide()

    item_row = button.closest('tr')
    variant_id = $('#stock_details').data('variant_id')
    stock_location_id = item_row.data('stock-location-id')
    quantity = item_row.find(".quantity").val()
    order = this.model

    $.ajax
      type: "POST"
      url: this.model.url() + "/line_items"
      data:
        line_item:
          variant_id: variant_id
          quantity: quantity
    .done (msg) ->
      order.fetch()
    .error (msg) ->
      console.error(msg)
