angularJS.controller "TicketsController", [
  "$http",
  "$scope",
  "$interval",
  "TicketFactory",
  "TicketStatusFactory",
  ($http, $scope, $interval, TicketFactory, TicketStatusFactory) ->
    $scope.statuses = TicketStatusFactory.getTicketStatuses()
    $scope.tickets = null
    $scope.populateTickets = ->

      doPopulateTickets = ->
        TicketFactory.getTickets().then (tickets) ->
          $scope.tickets = []
          $scope.hasFailed = (not (tickets?))
          return if $scope.hasFailed
          $scope.tickets = tickets
          $scope.showTicket()

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
      $scope.tickets

    $scope.commentDialogShow = ->
      $("#comment").val("")
      $("#newComment").on("shown.bs.modal", () -> 
        $("#comment").focus()
      )
      $("#newComment").modal('show')
      false

    $scope.commentDialogHide = -> 
      $('#newComment').modal('hide')
      false

    $scope.commentDialogSubmit = (ticket) ->
      comment = $("#comment").val()
      console.log(ticket)
      successHandler = (response) ->
        console.log(response.data)
        ticket.comments.push(new TicketComment(response.data.updateAuthor.emailAddress, response.data.body, null))
        $scope.commentDialogHide()
      errorHandler = (response) ->
        # handle gracefully
      request = $http({
        method: "post",
        url: "/support/api/tickets/" + ticket.reference + "/comments/",
        data: {
          "text": comment
        }
      })
      request.then successHandler, errorHandler

    $scope.commentDialogCancel = ->
      console.log("cancel")
      $scope.commentDialogHide()
      false

]