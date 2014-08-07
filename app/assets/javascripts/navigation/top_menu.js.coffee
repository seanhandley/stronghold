$ ->
  $('.top-menu-option').tooltip({})

  # Workaround for display bug with the navpills
  $('.dropdown').on 'shown.bs.dropdown', ->
    $('.nav-tabs').addClass 'hide'
  $('.dropdown').on 'hidden.bs.dropdown', ->
    $('.nav-tabs').removeClass 'hide'