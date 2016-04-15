angularJS.factory "TicketStatusFactory", ->

  statuses = null

  getTicketStatuses: ->

    if (!statuses)
      #"Open" Status
      openTicketStatus = new TicketStatus "Open"

      #"Closed" Status
      closedTicketStatus = new TicketStatus "Closed"
      statuses = [openTicketStatus, closedTicketStatus]

    #Return Statuses
    statuses

angularJS.factory "TicketPriorityFactory", ->
  getTicketPriorities: ->

   [new TicketPriority("Low"), new TicketPriority("Normal"), new TicketPriority("High"), new TicketPriority("Emergency")]