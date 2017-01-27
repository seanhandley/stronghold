$ ->
  $('#new_ticket_department').on "change", () ->
    if $('#new_ticket_department').val().length > 0
      if $('#new_ticket_department').val() == "Access Requests"
        $('#access-request-fields').removeClass('hide')
        $('#other-issues-fields').addClass('hide')
        $('#support-fields').addClass('hide')
      else if $('#new_ticket_department').val() == "Technical Support"
        $('#support-fields').removeClass('hide')
        $('#other-issues-fields').removeClass('hide')
        $('#access-request-fields').addClass('hide')
      else
        $('#other-issues-fields').removeClass('hide')
        $('#access-request-fields').addClass('hide')
        $('#support-fields').addClass('hide')
    else
      $('#other-issues-fields').addClass('hide')
      $('#access-request-fields').addClass('hide')
      $('#support-fields').addClass('hide')
