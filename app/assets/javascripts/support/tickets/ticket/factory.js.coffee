angularJS.factory "TicketFactory", ($http, TicketStatusFactory) ->

  getTickets: ->

    successHandler = (response) ->
      if response.status is not 200
        return null
      tickets = []
      angular.forEach response.data, (ticket, index) ->
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
          ticket.jira_status,
          null,
          ticket.email,
          comments,
          ticket.time_created,
          ticket.time_updated
        )
        tickets.push(newTicket)
      tickets

    errorHandler = (response) ->
      null

    $http.get("/support/api/tickets/").then successHandler, errorHandler