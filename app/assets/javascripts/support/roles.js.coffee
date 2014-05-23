$ ->
  $('.role-permission').click (e) ->
    $(e.currentTarget).parents('form').submit()

  $('.nav-tab a').click (e) ->
    e.preventDefault()
    $(this).tab('show')

  $('div.panel-heading').click (e) ->
    el = $(this).find("a[data-toggle='collapse']").attr('href')
    $(el).collapse('toggle')