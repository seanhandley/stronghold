angularJS.factory "TicketStatusFactory", ->

  statuses = null

  getTicketStatuses: ->

    if (!statuses)
      #"Open" Status
      openTicketStatus = new TicketStatus "Open", "#00CC00"
      openTicketStatus.addJiraStatus "To Do"
      openTicketStatus.addJiraStatus "In Progress"

      #"Closed" Status
      closedTicketStatus = new TicketStatus "Closed", "#CC0000"
      closedTicketStatus.addJiraStatus "Done"
      statuses = [openTicketStatus, closedTicketStatus]

    #Return Statuses
    statuses