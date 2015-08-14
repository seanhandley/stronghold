$ ->
  $("#project").chained("#organization")
  $('a.toggle_line_entry').click (e) ->
    e.preventDefault()
    id = $(this).data('id')
    $("." + id).toggleClass('hide')