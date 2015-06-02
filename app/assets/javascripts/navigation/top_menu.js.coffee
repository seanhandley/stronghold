$ ->
  $('.top-menu-option').tooltip({})
  $('.has-tooltip').tooltip({})


  # Workaround for display bug with the navpills
  $('.dropdown').on 'shown.bs.dropdown', ->
    $('#user-role-tabs').addClass 'hide'
  $('.dropdown').on 'hidden.bs.dropdown', ->
    $('#user-role-tabs').removeClass 'hide'