Backend.ApplicationSerializer = DS.ActiveModelSerializer.extend
  # Turns { id: 1, ... } into something like { order: { id: 1, ... } }
  extractFind: (store, type, oldPayload) ->
    newPayload = {}
    newPayload[type.typeKey] = oldPayload

    this._super(store, type, newPayload)

  normalizePayload: (type, payload) ->
    delete payload['count']
    delete payload['current_page']
    delete payload['pages']

    this._super.apply(this, arguments)
