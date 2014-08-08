angularJS.factory "TicketFactory", ($http) ->

  getTickets: ->

    successHandler = (response) ->
      if (response.statusText == "OK")
        response.data
      else
        null

    errorHandler = (response) ->
      null

    $http.get("/support/api/tickets/").then successHandler, errorHandler