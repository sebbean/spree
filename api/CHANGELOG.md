## Spree 2.3.0 (unreleased) ##

* Refactor the api to use a general importer in core gem.
    
    * Peter Berkenbosch

* Shipment manifests viewed within the context of an order no longer return variant info. The line items for the order already contains this information. #4498

    * Ryan Bigg