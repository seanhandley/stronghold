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
    //This was fun to fix. Turns out grep doesn't work like LINQ, and expects boolean false.
    $scope.tickets = [];
    $.each($scope.statuses, function(status_name, status) {
      $scope.tickets[status_name] = $.grep(tickets, function(ticket) {
        if ($.inArray(ticket.attrs.fields.status.name, status.jira_statuses)) {
          //console.log("for status " + status_name + ", do NOT include " + ticket.attrs.key + " as " + ticket.attrs.fields.status.name + " is in the next line:");
          //console.log(status.jira_statuses);
          return false;
        } else {
          return true;
        }
      });
    });
  });

  $scope.selectedTicket = null;
  $scope.showTicket = function(ticket) {
    $scope.selectedTicket = ticket;
  }

});