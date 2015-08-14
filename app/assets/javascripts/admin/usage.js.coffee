$ ->
  $("#project").chained("#organization")
  $('a.toggle_line_entry').click (e) ->
    e.preventDefault()
    id = $(this).data('id')
    console.log(id)
    link_text = $(this).text()
    console.log(link_text)
    console.log(link_text.charAt(0))
    if link_text.charAt(0) == "+"
      console.log(link_text.substring(1))
      $(this).text("-" + link_text.substring(1))
      $("." + id).removeClass('hide')
    else
      $(this).text("+" + link_text.substring(1))
      console.log(link_text.substring(1))
      $("." + id).addClass('hide')