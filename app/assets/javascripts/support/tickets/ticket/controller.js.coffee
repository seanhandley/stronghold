angularJS.controller "TicketsController", [
  "$http",
  "$scope",
  "$interval",
  "TicketFactory",
  "TicketStatusFactory",
  ($http, $scope, $interval, TicketFactory, TicketStatusFactory) ->

    $scope.statuses = TicketStatusFactory.getTicketStatuses()
    $scope.tickets = []

    $scope.isLoading = false

    $scope.doPopulateTickets = (dCallback = false) ->
      async.waterfall([
        (next) ->
          setTimeout(next, 1000)
          return
        (next) ->
          TicketFactory.getTickets().then (tickets) ->
            tickets = [] if (tickets == `null`)
            setTimeout(next(null, tickets), 1000)
          return
        (tickets, next) ->
          $scope.hasFailed = (not (tickets?))
          if (not $scope.hasFailed)
            $scope.tickets = tickets
            $scope.showTicket()
          $scope.$apply()
          dCallback() if dCallback
          return
      ])

    $scope.populateTickets = ->
      $scope.isLoading = true
      $scope.$apply()
      $scope.doPopulateTickets(() ->
        $scope.isLoading = false
        $scope.$apply()
        return
      )
      doPopulateTicketsPromise = $interval(
        () ->
          $scope.doPopulateTickets()
        , 10 * 1000
      )
      return

    $scope.getTickets = (status) ->
      return [] unless $scope.tickets?
      $.grep $scope.tickets, (ticket) ->
        ticket.status.name is status.name

    $scope.countTickets = ->
      $scope.tickets.length

    $scope.hasTickets = ->
      $scope.countTickets() > 0

    $scope.hasComments = (ticket) ->
      return false if !ticket?
      (ticket.comments.length > 0)

    $scope.getTicketByReference = (reference) ->
      return (
        $.grep $scope.tickets, (ticket) ->
          ticket.reference == reference
      )[0]

    $scope.selectedTicketReference = -1
    $scope.showTicket = (ticketReference) ->
      ticketReference = $scope.selectedTicketReference if ticketReference is `undefined`
      if ticketReference != null
        $scope.selectedTicket = $scope.getTicketByReference(ticketReference)
      else
        $scope.selectedTicket = null
      $scope.selectedTicketReference = ticketReference
      $scope.selectedTicket

    $scope.ticketDialogShow = ->
      ticketTitleInput = $("#new_ticket_title")
      ticketDescriptionTextArea = $("#new_ticket_description")
      ticketSubmitButton = $($("#newTicket button.btn-primary")[0])
      ticketDescriptionTextArea.val("")
      ticketTitleInput.val("")
      ticketSubmitButton.html("Submit")
      ticketSubmitButton.removeClass("disabled")
      $("#newTicket").on("shown.bs.modal", () -> 
        ticketTitleInput.focus()
      )
      $("#newTicket").modal('show')
      false

    $scope.ticketDialogHide = ->
      $('#newTicket').modal('hide')
      false

    $scope.ticketDialogSubmit = ->
      ticketTitleInput = $("#new_ticket_title")
      ticketDescriptionTextArea = $("#new_ticket_description")
      ticketSubmitButton = $($("#newTicket button.btn-primary")[0])
      ticketSubmitButton.html("Submitting...")
      ticketSubmitButton.addClass("disabled")
      allHandler = () ->
        $scope.ticketDialogHide()
      successHandler = (response) ->
        if (response.data.errorMessages)
          errorHandler()
          return
        $scope.doPopulateTickets()
        allHandler()
      errorHandler = (response) ->
        allHandler()
      request = $http({
        method: "post",
        url: "/support/api/tickets/",
        data: {
          "title": ticketTitleInput.val(),
          "description": ticketDescriptionTextArea.val()
        }
      })
      request.then successHandler, errorHandler

    $scope.ticketDialogCancel = ->
      $scope.ticketDialogHide()
      false

    $scope.commentDialogShow = ->
      commentTextArea = $("#new_comment_text")
      commentSubmitButton = $($("#newComment button.btn-primary")[0])
      commentTextArea.val("")
      commentSubmitButton.html("Submit")
      commentSubmitButton.removeClass("disabled")
      $("#newComment").on("shown.bs.modal", () -> 
        commentTextArea.focus()
      )
      $("#newComment").modal('show')
      false

    $scope.commentDialogHide = -> 
      $('#newComment').modal('hide')
      false

    $scope.commentDialogSubmit = ->
      commentTextArea = $("#new_comment_text")
      commentSubmitButton = $($("#newComment button.btn-primary")[0])
      commentSubmitButton.html("Submitting...")
      commentSubmitButton.addClass("disabled")
      allHandler = () ->
        $scope.commentDialogHide()
      successHandler = (response) ->
        if (response.data.errorMessages)
          errorHandler()
          return
        $scope.doPopulateTickets()
        allHandler()
      errorHandler = (response) ->
        allHandler()
      request = $http({
        method: "post",
        url: "/support/api/tickets/" + $scope.selectedTicket.reference + "/comments/",
        data: {
          "text": commentTextArea.val()
        }
      })
      request.then successHandler, errorHandler

    $scope.commentDialogCancel = ->
      $scope.commentDialogHide()
      false

    $scope.changeStatus = (status) ->
      url = "/support/api/tickets/" + $scope.selectedTicket.reference + "/"
      data = {
        "status": status.jira_statuses[status.primary_jira_status]
      }
      allHandler = () ->
        # ...
      successHandler = (response) ->
        if (response && response.data.errorMessages)
          errorHandler()
          return
        $scope.selectedTicket.status = status
        allHandler()
      errorHandler = (response) ->
        allHandler()
      request = $http({
        method: "patch",
        url: url
        data: data
      })
      request.then successHandler, errorHandler

]