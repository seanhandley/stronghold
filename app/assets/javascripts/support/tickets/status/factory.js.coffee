angularJS.factory "StatusesFactory", ->
  getStatuses: ->

    #"Open" Status
    openStatus = new Status "Open", "#00CC00"
    openStatus.addJiraStatus "To Do"
    openStatus.addJiraStatus "In Progress"

    #"Closed" Status
    closedStatus = new Status "Closed", "#CC0000"
    closedStatus.addJiraStatus "Done"

    #Return Statuses
    statuses = [openStatus, closedStatus]