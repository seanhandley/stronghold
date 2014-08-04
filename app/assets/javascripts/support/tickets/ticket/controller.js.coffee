angularJS.controller "TicketsController", [
  "$scope",
  "$interval",
  "TicketsFactory",
  "StatusesFactory",
  ($scope, $interval, TicketsFactory, StatusesFactory) ->
    $scope.statuses = StatusesFactory.getStatuses()
    $scope.tickets = null
    $scope.populateTickets = ->

      doPopulateTickets = ->
        TicketsFactory.getTickets().then (tickets) ->
          $scope.tickets = []
          $scope.hasFailed = (not (tickets?))
          return if $scope.hasFailed
          angular.forEach tickets, (ticket, index) ->
            applicableStatuses = $.grep $scope.statuses, (status) ->
              $.inArray(ticket.jira_status, status.jira_statuses) >= 0
            ticket.status = applicableStatuses[0]
          $scope.tickets = tickets
          tickets

      doPopulateTickets()
      doPopulateTicketsPromise = $interval(doPopulateTickets, 5000)
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

    $scope.selectedTicket = null
    $scope.showTicket = (ticket) ->
      $scope.selectedTicket = ticket

]