supportAngularJSApp.factory "TicketsFactory", ($http) ->
  getTickets: ->
    successHandler = (response) ->
      return null unless response.statusText is "OK"
      tickets = []
      angular.forEach response.data, (responseTicket, index) ->

        #Fresh Ticket
        newTicket = new Ticket()

        #Backend -> Frontend Mapping
        newTicket.jira_status = responseTicket.attrs.fields.status.name
        newTicket.reference = responseTicket.attrs.key
        newTicket.title = responseTicket.attrs.fields.summary
        newTicket.description = responseTicket.attrs.fields.description

        #Comment Simulation
        newTicket.comments = [
          new Comment(
            null,
            "This rocks!",
            moment([2013, 11, 25])
          ),
          new Comment(
            null,
            "This sucks.",
            moment([2013, 11, 27])
          )
        ]

        #Push
        tickets.push newTicket

      tickets

    errorHandler = (response) ->
      null

    $http.get("/support/api/tickets/").then successHandler, errorHandler