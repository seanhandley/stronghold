$ ->
  $("#project").chained("#organization")
  $('a.toggle_line_entry').click ->
    id = $(this).data('id')
    $("." + id).toggleClass('hide')