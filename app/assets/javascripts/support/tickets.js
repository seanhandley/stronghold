stronghold.factory('StatusesFactory', function() {
  return {
    getStatuses: function() {
      //"Open" Status
      var openStatus = new Status();
      openStatus.name = "Open";
      openStatus.color = "#00CC00";
      openStatus.addJiraStatus('To Do');
      openStatus.addJiraStatus('In Progress');
      //"Closed" Status
      var closedStatus = new Status();
      closedStatus.name = "Closed";
      closedStatus.color = "#CC0000";
      closedStatus.addJiraStatus('Done');
      //Return Statuses
      var statuses = [openStatus, closedStatus];
      console.log(statuses);
      return statuses;
    }
  };
});

stronghold.factory('TicketsFactory', function($http) {
  return {
    getTickets: function() {

      var successHandler = function(response) {
        if (response.statusText != "OK") return null;
        var tickets = [];
        $.each(response.data, function(index, rubyTicket) {

          //Debug
          //console.log(rubyTicket);

          //Fresh Ticket
          var newTicket = new Ticket();

          //Current Backend Bodges
          newTicket.jira_status = "Done";
          newTicket.reference = rubyTicket.attrs.key;
          newTicket.title = rubyTicket.attrs.fields.summary;
          newTicket.description = rubyTicket.attrs.fields.description;

          //Comment Simulation
          newTicket.comments = [
            new Comment(null, "This rocks!", moment("2013-25-12")),
            new Comment(null, "This sucks.", moment("2013-26-12"))
          ];

          //Debug
          console.log(newTicket);

          //Push
          tickets.push(newTicket);

        });
        return tickets;
      }

      var errorHandler = function(response) {
        return null;
      }

      return $http.get('/support/api/tickets/').then(successHandler, errorHandler);

    }
  };
});

stronghold.controller('TicketsController', function($scope, TicketsFactory, StatusesFactory) {

  $scope.statuses = StatusesFactory.getStatuses();

  $scope.tickets = null;
  $scope.getTickets = function() {
    TicketsFactory.getTickets().then(function(tickets) {
      $scope.tickets = [];
      $scope.hasFailed = (tickets == null);
      if ($scope.hasFailed) return;
      $.each(tickets, function(index, ticket) {
        var applicableStatuses = $.grep($scope.statuses, function(status) {
          return ($.inArray(ticket.jira_status, status.jira_statuses) >= 0);
        });
        ticket.status = applicableStatuses[0];
      });
      $.each($scope.statuses, function(index, status) {
        $scope.tickets[status.name] = $.grep(tickets, function(ticket) {
          return (ticket.status.name == status.name);
        });
      });
    });
  }

  $scope.countTickets = function() {
    var t = 0;
    if ($scope.tickets != null) {
      for (var index in $scope.tickets) t += $scope.tickets[index].length;
    }
    return t;
  }

  $scope.hasTickets = function() {
    return ($scope.countTickets() > 0);
  }

  $scope.isLoading = function() {
    return ($scope.tickets == null);
  }

  $scope.selectedTicket = null;
  $scope.showTicket = function(ticket) {
    $scope.selectedTicket = ticket;
  }

});

$(document).ready(function() {
  $("#statusDropdown a").click(function() {
    var element = $(this);
    var status = null;
    var scope = angular.element(element).scope();
    scope.$apply(function(){
      status = $.grep(scope.statuses, function(value) {
        //console.log(element.attr("status-name") + ", " + value.name);
        return(value.name == element.attr("status-name"));
      })[0];
    });
    console.log("Change JIRA status to be " + status.jira_statuses[status.primary_jira_status]);
  });
});