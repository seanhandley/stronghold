angularJS.factory "TicketFactory", ($http, TicketStatusFactory) ->

  getTickets: ->

    successHandler = (response) ->
      if (response.statusText == "OK")
        tickets = []
        angular.forEach response.data, (ticket, index) ->
          applicableStatuses = $.grep TicketStatusFactory.getTicketStatuses(), (status) ->
            $.inArray(ticket.jira_status, status.jira_statuses) >= 0
          # Comments
          comments = []
          angular.forEach ticket.comments, (comment, index) ->
            newComment = new TicketComment comment.email, comment.content, comment.time
            comments.push(newComment)
          # Ticket
          newTicket = new Ticket(
            ticket.reference,
            ticket.title,
            ticket.description,
            applicableStatuses[0],
            "e-mail",
            comments,
            ticket.time_created,
            ticket.time_updated
          )
          tickets.push(newTicket)
        tickets
      else
        null

    errorHandler = (response) ->
      null

    $http.get("/support/api/tickets/").then successHandler, errorHandler