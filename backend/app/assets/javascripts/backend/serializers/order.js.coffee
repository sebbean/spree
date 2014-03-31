#= require backend/serializers/application

Backend.OrderSerializer = Backend.ApplicationSerializer.extend DS.EmbeddedRecordsMixin,
  primaryKey: 'number'
  attrs:
    line_items:
      embedded: 'always'
    shipments: 
      embedded: 'always'