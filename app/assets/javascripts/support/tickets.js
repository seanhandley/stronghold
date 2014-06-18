var stronghold = angular.module("stronghold", []);

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

  statuses = [
    {
      "name": "open",
      "jira_statuses": ['To Do', 'In Progress']
    },
    {
      "name": "closed",
      "jira_statuses": ['Done']
    }
  ];

  TicketsFactory.getTickets().then(function(tickets) {
    $scope.tickets = [];
    $.each(statuses, function(status_index, status) {
      $scope.tickets[status.name] = $.grep(tickets, function(ticket) {
        console.log(ticket);
        return $.inArray(ticket.attrs.fields.status.name, status.jira_statuses);
      });
    });
  });

});