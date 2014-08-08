angularJS.controller "TicketsController", [
  "$scope",
  "$interval",
  "TicketFactory",
  "TicketStatusFactory",
  ($scope, $interval, TicketFactory, TicketStatusFactory) ->
    $scope.statuses = TicketStatusFactory.getTicketStatuses()
    $scope.tickets = null
    $scope.populateTickets = ->

      doPopulateTickets = ->
        TicketFactory.getTickets().then (tickets) ->
          $scope.tickets = []
          $scope.hasFailed = (not (tickets?))
          return if $scope.hasFailed
          angular.forEach tickets, (ticket, index) ->
            applicableStatuses = $.grep $scope.statuses, (status) ->
              $.inArray(ticket.jira_status, status.jira_statuses) >= 0
            ticket.status = applicableStatuses[0]
            console.log(ticket)
          $scope.tickets = tickets
          $scope.showTicket()
          tickets

      doPopulateTickets()
      doPopulateTicketsPromise = $interval(doPopulateTickets, 20 * 1000)
      return

    $scope.getTickets = (status) ->
      return [] unless $scope.tickets?
      $.grep $scope.tickets, (ticket) ->
        ticket.status.name is status.name

    $scope.countTickets = ->
      return 0 unless $scope.tickets?
      $scope.tickets.length

    $scope.hasTickets = ->
      $scope.countTickets() > 0

    $scope.isLoading = ->
      not $scope.tickets?

    $scope.selectedTicketIndex = -1
    $scope.showTicket = (ticketIndex) ->
      ticketIndex = $scope.selectedTicketIndex if ticketIndex is `undefined`
      ticketIndex = -1 if $scope.tickets[ticketIndex] is `undefined`
      if ticketIndex > -1
        $scope.selectedTicket = $scope.tickets[ticketIndex]
      else
        $scope.selectedTicket = null
      $scope.selectedTicketIndex = ticketIndex

]