// For more information see: http://emberjs.com/guides/routing/

Backend.Router.map(function() {
  this.resource('orders', { path: '/admin/orders'});
  this.resource('order', { path: '/admin/orders/:number' });
  this.resource('order.state', { path: '/admin/orders/:number/:state' });
});

Backend.Router.reopen({
  location: 'history'
});
