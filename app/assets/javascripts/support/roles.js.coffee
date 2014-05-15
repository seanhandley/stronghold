$ ->
  $('.role-permission').click (e) ->
    $(e.currentTarget).parents('form').submit()