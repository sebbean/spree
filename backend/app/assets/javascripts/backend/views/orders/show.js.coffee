Backend.OrdersShowView = Ember.View.extend
  didChangeState: (->
    # Set the currently active state
    $('.state_indicator').removeClass('active')
    current_state = this.controller.get('model.current_state')
    $("##{current_state}_state").addClass('active')
    # Hide all other bits of information
    $('.state_info').hide()
    $("##{current_state}_info").show()
  ).observes('controller.model.current_state')

  didInsertElement: ->
    this.didChangeState()