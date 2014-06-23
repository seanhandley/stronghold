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

  $scope.statuses = {
    "open":
    {
      "color": "green",
      "jira_statuses": ['To Do', 'In Progress']
    },
    "closed":
    {
      "color": "red",
      "jira_statuses": ['Done']
    }
  };

  TicketsFactory.getTickets().then(function(tickets) {
    $scope.tickets = [];
    $.each($scope.statuses, function(status_name, status) {
      $scope.tickets[status_name] = $.grep(tickets, function(ticket) {
        return (!($.inArray(ticket.attrs.fields.status.name, status.jira_statuses)));
      });
    });
    console.log(JSON.stringify($scope.tickets["closed"][0]));
  });

  $scope.selectedTicket = null;
  $scope.showTicket = function(ticket) {
    $scope.selectedTicket = ticket;
  }

});