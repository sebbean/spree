$(document).ready ->
  $('#refunds form').submit ->
    form = $(this)
    $.post(form.data('url'),
      {
        refund: {
          variant_id: form.find('#variant_id').val()
          quantity: form.find('#quantity').val()
        }
      } 
    ).done (response) ->
      #comment
    false