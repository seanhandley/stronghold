var stronghold = angular.module("stronghold", []);

// def closed
//   all.select do |issue|
//     [
//       (issue.fields['status']['name'] == IssueStatus::Done)
//     ].all?
//   end
// end

// module IssueStatus
//   ToDo       = 'To Do'
//   InProgress = 'In Progress'
//   Done       = 'Done'
// end

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

  TicketsFactory.getTickets().then(function(tickets) {
    $scope.tickets = tickets;
  });

  $scope.getTickets = function(status) {
    console.log($scope);
    $scope.tickets = $.grep($scope.tickets, function(ticket) {
      var ticketStatus = ticket["attrs"]["fields"]["status"]["name"];
      console.log(ticketStatus);
      switch(status) {
        case "open":
          return (ticketStatus === "To Do" || ticketStatus === "In Progress");
          break;
        case "closed":
          return (ticketStatus === "Done");
          break;
        default:
          return false;
          break;
      }
    });
  }

});