stronghold.factory('TicketsFactory', function($http) {
  return {
    getTickets: function() {

      var successHandler = function(response) {
        if (response.statusText != "OK") return null;
        console.log(response.data);
        return response.data;
        var tickets = [];
        $.each(response.data, function(index, jiraIssue) {
          tickets.push(
            {
              "test_property": "test_value",
              "something": "something_else"
            }
          );
        });
        console.log(tickets);
        return tickets;
      }

      var errorHandler = function(response) {
        return null;
      }

      return $http.get('/support/api/tickets/').then(successHandler, errorHandler);

    }
  };
});

stronghold.controller('TicketsController', function($scope, TicketsFactory) {

  $scope.statuses = [
    {
      "name": "Open",
      "color": "#00CC00",
      "jira_statuses": ['To Do', 'In Progress']
    },
    {
      "name": "Closed",
      "color": "#CC0000",
      "jira_statuses": ['Done']
    }
  ];

  $scope.tickets = null;
  $scope.getTickets = function() {
    TicketsFactory.getTickets().then(function(tickets) {
      $scope.tickets = [];
      $scope.hasFailed = (tickets == null);
      if (!($scope.hasFailed)) {
        $.each($scope.statuses, function(index, status) {
          $scope.tickets[status.name] = $.grep(tickets, function(ticket) {
            //return false;
            return (!($.inArray(ticket.attrs.fields.status.name, status.jira_statuses)));
          });
          $.each($scope.tickets[status.name], function(index, ticket) {
            //console.log(ticket);
            ticket.status = status;
          });          
        });
      }
    });
  }

  $scope.countTickets = function() {
    var t = 0;
    if ($scope.tickets != null) {
      for (var index in $scope.tickets) {
        t += $scope.tickets[index].length;
      }
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