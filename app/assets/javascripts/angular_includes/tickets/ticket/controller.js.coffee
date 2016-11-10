angularJS.controller "TicketsController", [
  "$http",
  "$scope",
  "$interval",
  "TicketFactory",
  "TicketStatusFactory",
  "TicketPriorityFactory",
  ($http, $scope, $interval, TicketFactory, TicketStatusFactory, TicketPriorityFactory) ->


    $scope.clearErrors = () ->
      $scope.staticError = null
      $scope.errors = []

    $scope.staticError = null
    $scope.errors = []
    $scope.statuses = TicketStatusFactory.getTicketStatuses()
    $scope.priorities = TicketPriorityFactory.getTicketPriorities()
    $scope.tickets = null
    $scope.hasFailed = null

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
          # console.log($scope.tickets)
          $scope.$apply() if !$scope.$$phase
          dCallback() if dCallback
          return
      ])

    $scope.populateTickets = ->
      $scope.isLoading = true
      $scope.$apply() if !$scope.$$phase
      $(window).on "popstate", (e) ->
        if e.state
          $scope.showTicket(e.state.reference)
      $scope.doPopulateTickets(() ->
        $scope.isLoading = false
        $scope.$apply() if !$scope.$$phase
        return if $scope.tickets is null
        permanentTicketReference = $("#tickets-container").attr("data-permanent-reference")
        if permanentTicketReference?
          $scope.showTicket(permanentTicketReference)
          ticket = $scope.getTicketByReference(permanentTicketReference)
          angular.forEach $scope.statuses, (status) ->
            status.active = false
          $scope.getStatusByName(ticket.status_name).active = true
          $scope.$apply() if !$scope.$$phase
        return
      , true, true)
      doPopulateTicketsPromise = $interval(
        () ->
          $scope.doPopulateTickets(null, false)
        , 10 * 1000, false)
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
      return 0 if $scope.tickets is null
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
      else
        $scope.selectedTicket = null
      history.replaceState({reference: ticketReference}, '', ticketReference)
      $scope.$apply() if !$scope.$$phase
      return

    $scope.ticketDialogShow = ->
      $scope.clearErrors()
      ticketTitleInput = $("#new_ticket_title")
      ticketDescriptionTextArea = $("#new_ticket_description")
      ticketDepartmentSelect = $("#new_ticket_department")
      ticketVisitorNames = $("#visitor_names")
      ticketPrioritySelect = $("#new_ticket_priority")
      ticketReasonForVisit = $("#reason_for_visit")
      ticketDateMinutes = $('#ticket_date_5i')
      ticketDateHours = $('#ticket_date_4i')
      ticketDateDay = $('#ticket_date_3i')
      ticketDateMonth = $('#ticket_date_2i')
      ticketDateYear = $('#ticket_date_1i')
      ticketSubmitButton = $($("#newTicket button.btn-primary")[0])
      ticketDescriptionTextArea.val("")
      ticketTitleInput.val("")
      ticketDepartmentSelect.val("")
      ticketVisitorNames.val("")
      ticketReasonForVisit.val("")
      ticketDateMinutes.val("00")
      ticketPrioritySelect.val("Normal")
      # ticketDateHours.val("")
      # ticketDateDay.val("")
      # ticketDateMonth.val("")
      # ticketDateYear.val("")
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
      ticketDepartmentSelect = $("#new_ticket_department")
      ticketPrioritySelect = $("#new_ticket_priority")
      ticketMoreInfo = $("#more_info")
      ticketVisitorNames = $("#visitor_names")
      ticketReasonForVisit = $("#reason_for_visit")
      ticketDateMinutes = $('#ticket_date_5i')
      ticketDateHours = $('#ticket_date_4i')
      ticketDateDay = $('#ticket_date_3i')
      ticketDateMonth = $('#ticket_date_2i')
      ticketDateYear = $('#ticket_date_1i')
      ticketSubmitButton = $($("#newTicket button.btn-primary")[0])
      ticketSubmitButton.html("Submitting...")
      ticketSubmitButton.addClass("disabled")
      allHandler = () ->
        ticketSubmitButton.html("Submit")
        ticketSubmitButton.removeClass("disabled")
      successHandler = (response) ->
        if not response.data.success
          $scope.errors = response.data.message
        else
          newTicketReference = response.data.message
          $scope.doPopulateTickets(() ->
            $scope.showTicket(newTicketReference)
            allHandler()
          , false)
          $scope.ticketDialogHide()
        allHandler()
        return
      errorHandler = (response) ->
        $scope.staticError = "I couldn't submit your ticket. Sorry. (HTTP 500)"
        window.location.replace('/account/tickets') if response.status == 401
        allHandler()
        return
      request = $http({
        method: "post",
        url: "/account/api/tickets/",
        data: {
          "title": ticketTitleInput.val(),
          "description": ticketDescriptionTextArea.val(),
          "department": ticketDepartmentSelect.val(),
          "priority": ticketPrioritySelect.val(),
          "more_info": ticketMoreInfo.val(),
          "visitor_names": ticketVisitorNames.val(),
          "nature_of_visit": ticketReasonForVisit.val(),
          "time_of_visit": ticketDateHours.val() + ":" + ticketDateMinutes.val(),
          "date_of_visit": ticketDateDay.val() + '/' + ticketDateMonth.val() + '/' + ticketDateYear.val(),
        }
      })
      request.then successHandler, errorHandler

    $scope.ticketDialogCancel = ->
      $scope.ticketDialogHide()
      false

    $scope.commentDialogShow = ->
      $scope.clearErrors()
      commentTextArea = $("#new_comment_text")
      commentSubmitButton = $($("#newComment button.btn-primary")[0])
      commentTextArea.val("")
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
        commentSubmitButton.html("Submit")
        commentSubmitButton.removeClass("disabled")
      successHandler = (response) ->
        if not response.data.success
          $scope.errors = response.data.message
        else
          $scope.doPopulateTickets(null, false)
          $scope.commentDialogHide()
        allHandler()
        return
      errorHandler = (response) ->
        $scope.staticError = "I couldn't submit your reply. Sorry. (HTTP 500)"
        window.location.replace('/account/tickets') if response.status == 401
        allHandler()
        return
      request = $http({
        method: "post",
        url: "/account/api/tickets/" + $scope.selectedTicket.reference + "/comments/",
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
      url = "/account/api/tickets/" + $scope.selectedTicket.reference + "/"
      data = {
        "status": status_name
      }
      allHandler = () ->
        setTimeout(() ->
          $scope.$apply() if !$scope.$$phase
        , 100)

      successHandler = (response) ->
        if not response.data.success
          errorHandler()
          return
        $scope.selectedTicket.status_name = status_name
        $scope.getStatusByName(status_name).active = true
        allHandler()
        return
      errorHandler = (response) ->
        window.location.replace('/account/tickets') if response.status == 401
        allHandler()
        return
      request = $http({
        method: "patch",
        url: url,
        data: data
      })
      request.then successHandler, errorHandler

    $scope.changePriority = (priority_name) ->
      emergency_message = "Emergency tickets will be answered ASAP by on-call staff and should not be used unless absolutely necessary. Do you wish to proceed?"
      if priority_name == 'Emergency' and !confirm(emergency_message)
        return

      priorityDropdownSpan = $("#priorityDropdown > span").not(".caret")
      priorityDropdownSpan.html("Changing...")
      url = "/account/api/tickets/" + $scope.selectedTicket.reference + "/"

      allHandler = () ->
        setTimeout(() ->
          $scope.$apply() if !$scope.$$phase
        , 100)

      successHandler = (response) ->
        if not response.data
          errorHandler()
        allHandler()

      errorHandler = (response) ->
        console.log("There was an error")

      request = $http({
        method: "patch",
        url: url,
        data: {
          "priority": priority_name
        }
      })

      request.then successHandler, errorHandler
]
