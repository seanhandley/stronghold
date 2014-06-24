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
      "color": "green",
      "jira_statuses": ['To Do', 'In Progress']
    },
    {
      "name": "Closed",
      "color": "red",
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
    if ($scope.tickets == null) return null;
    var t = 0;
    for (var index in $scope.tickets) {
      t += $scope.tickets[index].length;
    }
    return t;
  }

  $scope.selectedTicket = null;
  $scope.showTicket = function(ticket) {
    $scope.selectedTicket = ticket;
  }

});