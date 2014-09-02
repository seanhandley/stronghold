angularJS.factory "TicketFactory", ($http, TicketStatusFactory) ->

  getTickets: ->

    successHandler = (response) ->
      if response.status is not 200
        return null
      response.data.sort((a, b) ->
        if a.time_updated > b.time_updated
          -1
        else
          1
      )
      response.data

    errorHandler = (response) ->
      null

    $http.get("/support/api/tickets/").then successHandler, errorHandler