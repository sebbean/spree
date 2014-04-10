Spree.LineItem = Backbone.Model.extend
  url: ->
    "/api/orders/#{this.order().id}/line_items/#{this.id}"

  variant: ->
    this.get('variant')

  order: ->
    this.get('order')

  advanceOrder: ->
    this.order().advance()

Spree.Admin.LineItemShow = Backbone.View.extend
  className: "line-item"
  tagName: "tr"
  render: ->
    template = _.template($("#line_item_template").html(), { line_item: this.model })
    this.$el.html(template)

  events:
    "click a.edit" : "toggleEdit"
    "click a.cancel": "toggleEdit"
    "click a.save": "save"
    "click a.delete": "delete"

  toggleEdit: (e) ->
    e.preventDefault()
    el = this.$el
    el.find("a.edit").toggle()
    el.find("a.cancel").toggle()
    el.find("a.save").toggle()
    el.find("a.delete").toggle()
    el.find("td.item-qty-show").toggle()
    el.find("td.item-qty-edit").toggle()

  save: (e) ->
    e.preventDefault()
    quantity = parseInt(this.$el.find("input.line_item_quantity").val())
    this.toggleEdit(e)
    this.$el.find("td.item-qty-show, td.item-total").html("<div align='center'><img src='/assets/spinner.gif'></div>")
    line_item = this.model
    $.ajax
      type: "PUT",
      url: Spree.url(line_item.url()),
      data:
        line_item:
          quantity: quantity
    .done (msg) ->
      line_item.advanceOrder()

  delete: (e) ->
    view = this
    line_item = view.model
    e.preventDefault()
    if confirm(Spree.translations.are_you_sure_delete)
      this.toggleEdit(e)
      $.ajax
        type: "DELETE"
        url: Spree.url(line_item.url())
      .done (msg) ->
        view.remove()
        line_item.advanceOrder()
        if $('#line-items tr.line-item').length == 0
          $('.line-items').hide()