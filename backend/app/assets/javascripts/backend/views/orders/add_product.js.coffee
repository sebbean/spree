Backend.OrdersAddProductView = Ember.View.extend
  didInsertElement: ->
    view = this

    $('#add_variant_id').select2
      placeholder: Spree.translations.variant_placeholder
      minimumInputLength: 3
      ajax:
        url: "/api/variants"
        datatype: "json"
        data: (term, page) ->
          q:
            product_name_or_sku_cont: term

        results: (data, page) ->
          results: data["variants"]

      formatResult: (variant) ->
        if variant.images[0]
          variant.image_url = variant.images[0].mini_url
        variantTemplate = Ember.TEMPLATES['variants/autocomplete.raw']
        variantTemplate(variant: variant)
      formatSelection: (variant) ->
        if !!variant.options_text
          variant.name + " (#{variant.options_text})"
        else
          variant.name