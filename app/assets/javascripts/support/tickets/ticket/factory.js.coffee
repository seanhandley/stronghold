angularJS.factory "TicketFactory", ($http, TicketStatusFactory) ->

  getTickets: (page=1) ->

    successHandler = (response) ->
      if response.status is not 200
        return null
      response.data

    errorHandler = (response) ->
      null

    $http.get("/account/api/tickets?page=" + page).then successHandler, errorHandler