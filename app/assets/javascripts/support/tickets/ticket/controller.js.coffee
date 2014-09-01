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

    $scope.doPopulateTickets = (dCallback = false, takeTime = false) ->
      async.waterfall([
        (next) ->
          if takeTime
            setTimeout(next, 1000)
          else
            next()
          return
        (next) ->
          TicketFactory.getTickets().then (tickets) ->
            tickets = [] if (tickets == `null`)
            if takeTime
               setTimeout(next(null, tickets), 1000)
            else
               next(null, tickets)
          return
        (tickets, next) ->
          $scope.hasFailed = (not (tickets?))
          if (not $scope.hasFailed)
            $scope.tickets = tickets
            $scope.showTicket(null)
          $scope.$apply()
          dCallback() if dCallback
          return
      ])

    $scope.populateTickets = ->
      $scope.isLoading = true
      $scope.$apply()
      $(window).on "popstate", (e) ->
        if e.state
          $scope.showTicket(e.state.reference)
      $scope.doPopulateTickets(() ->
        $scope.isLoading = false
        $scope.$apply()
        permanentTicketReference = $("#tickets-container").attr("data-permanent-reference")
        $scope.showTicket(permanentTicketReference) if permanentTicketReference?
        return
      , true)
      doPopulateTicketsPromise = $interval(
        () ->
          $scope.doPopulateTickets(null, false)
        , 10 * 1000
      )
      return

    $scope.getStatusByName = (name) ->
      statuses = $.grep $scope.statuses, (status) ->
        status.name is name
      statuses[0]

    $scope.isStatusActiveByName = (name) ->
      $scope.getStatusByName(name).active

    $scope.getTicketsByStatus = (status) ->
      return [] unless $scope.tickets?
      $.grep $scope.tickets, (ticket) ->
        ticket.status_name is status.name

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

    $scope.selectedTicketReference = null
    $scope.showTicket = (ticketReference) ->
      ticketReference = $scope.selectedTicketReference if ticketReference is `null`
      if ticketReference != null
        $scope.selectedTicket = $scope.getTicketByReference(ticketReference)
        $scope.selectedTicketReference = ticketReference
        if $scope.selectedTicket isnt `undefined`
          $scope.getStatusByName($scope.selectedTicket.status_name).active = true
      else
        $scope.selectedTicket = null
      history.replaceState({reference: ticketReference}, '', ticketReference)
      $scope.$apply()
      return

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
        console.log(response.data)
        if (response.data.errorMessages)
          errorHandler()
          return
        newTicketReference = response.data
        $scope.doPopulateTickets(() ->
          $scope.showTicket(newTicketReference)
          allHandler()
        , false)
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
        $scope.doPopulateTickets(null, false)
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

    $scope.changeStatus = (status_name) ->
      statusDropdownSpan = $("#statusDropdown > span").not(".caret")
      statusDropdownSpan.html("Changing...")
      url = "/support/api/tickets/" + $scope.selectedTicket.reference + "/"
      data = {
        "status": status_name
      }
      allHandler = () ->
        setTimeout(() ->
          $scope.$apply()
        , 100)

      successHandler = (response) ->
        if (response && response.data.errorMessages)
          errorHandler()
          return
        $scope.selectedTicket.status_name = status_name
        $scope.getStatusByName(status_name).active = true
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