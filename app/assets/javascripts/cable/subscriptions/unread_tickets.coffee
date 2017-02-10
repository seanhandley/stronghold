App.cable.subscriptions.create { channel: "UnreadTicketsChannel" },
  received: (data) ->
    if data['unread_count'] == 0
      $('#unread-support-tickets').text('')
    else
      if data['play_sounds'] && data['increased']
        ion.sound.stop()
        ion.sound.play("water_droplet")
      $('#unread-support-tickets').text(data['unread_count'])
      $("#unread-support-tickets").pulse({"font-size": "18px"}, {duration : 1000, pulses : 1, duration: 400})
    if typeof angular != 'undefined'
      angular.element(document.getElementById('tickets-container')).scope().doPopulateTickets()