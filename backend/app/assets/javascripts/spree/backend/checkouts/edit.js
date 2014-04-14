//= require_self
$(document).ready(function() {

  var order_use_billing_input = $('input#order_use_billing');

  var order_use_billing = function () {
    if (!order_use_billing_input.is(':checked')) {
      $('#shipping').show();
    } else {
      $('#shipping').hide();
    }
  };

  order_use_billing_input.click(function() {
    order_use_billing();
  });

  order_use_billing();

  $('#guest_checkout_true').change(function() {
    $('#customer_search').val("");
    $('#user_id').val("");
    $('#checkout_email').val("");

    var fields = ["firstname", "lastname", "company", "address1", "address2",
              "city", "zipcode", "state_id", "country_id", "phone"]
    $.each(fields, function(i, field) {
      $('#order_bill_address_attributes' + field).val("");
      $('#order_ship_address_attributes' + field).val("");
    })
  });
});
