$ ->
  $("#project").chained("#organization")
  $('a.toggle_line_entry').click (e) ->
    e.preventDefault()
    id = $(this).data('id')
    link_text = $(this).text()
    if link_text.substring(0,1) == "+"
      $(this).text("-" + link_text.substring(1))
      $("." + id).removeClass('hide')
    else
      $(this).text("+" + link_text.substring(1))
      $("." + id).addClass('hide')