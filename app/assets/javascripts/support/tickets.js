stronghold.factory('TicketsFactory', function($http) {
  return {
    getTickets: function() {
      return $http.get('/support/api/tickets/').then(function(result) {
        return result.data;
      });
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
      $.each($scope.statuses, function(index, status) {
        $scope.tickets[status.name] = $.grep(tickets, function(ticket) {
          //return false;
          return (!($.inArray(ticket.attrs.fields.status.name, status.jira_statuses)));
        });
      });
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
    var x = ($scope.countTickets() > 0);
    console.log("htc: " + $scope.countTickets());
    console.log(x);
    return x;
    //return ($scope.countTickets() != null || $scope.countTickets() > 0);
  }

  $scope.isLoading = function() {
    return ($scope.tickets == null);
  }

  $scope.selectedTicket = null;
  $scope.showTicket = function(ticket) {
    $scope.selectedTicket = ticket;
  }

});