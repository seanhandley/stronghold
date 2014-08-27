angularJS.factory "TicketStatusFactory", ->

  statuses = null

  getTicketStatuses: ->

    if (!statuses)
      #"Open" Status
      openTicketStatus = new TicketStatus "Open"
      openTicketStatus.addJiraStatus "To Do"
      openTicketStatus.addJiraStatus "In Progress"

      #"Closed" Status
      closedTicketStatus = new TicketStatus "Closed"
      closedTicketStatus.addJiraStatus "Done"
      statuses = [openTicketStatus, closedTicketStatus]

    #Return Statuses
    statuses