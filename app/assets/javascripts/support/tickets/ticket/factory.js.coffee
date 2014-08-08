angularJS.factory "TicketFactory", ($http, TicketStatusFactory) ->

  getTickets: ->

    successHandler = (response) ->
      if (response.statusText == "OK")
        angular.forEach response.data, (ticket, index) ->
          applicableStatuses = $.grep TicketStatusFactory.getTicketStatuses(), (status) ->
            $.inArray(ticket.jira_status, status.jira_statuses) >= 0
          ticket.status = applicableStatuses[0]
          backupTickets = ticket.comments.slice() # copy
          ticket.comments = []
          angular.forEach backupTickets, (comment, index) ->
            newComment = new TicketComment comment.email, comment.content, moment(comment.time)
            ticket.comments.push(newComment)
        response.data
      else
        null

    errorHandler = (response) ->
      null

    $http.get("/support/api/tickets/").then successHandler, errorHandler