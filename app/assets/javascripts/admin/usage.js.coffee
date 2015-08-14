$ ->
  $("#project").chained("#organization")
  $('a.toggle_line_entry').click ->
    id = $(this).data('id')
    $("line_entry_" + id).toggleClass('hide')