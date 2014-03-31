module("Integration Tests ", {
  setup: function() {
    $.mockjax({
      url: 'http://localhost:3000/api/orders',
      responseText: {
        orders: [{
          number: 'R123456789'
        }]
      }
    })
    Backend.reset();
  },
  teardown: function () {
    $.mockjaxClear();
  }
});

test("front page for non-signed in users", function() {
  visit("/admin/orders");
  andThen(function() {
    equal(find("#listing_orders tbody tr").length, 1, "Order visible");
  });
}); 