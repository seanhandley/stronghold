$ ->
  $('.role-permission').click (e) ->
    $(e.currentTarget).parents('form').submit()

  $('.nav-tab a').click (e) ->
    e.preventDefault()
    $(this).tab('show')