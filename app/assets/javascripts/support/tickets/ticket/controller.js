supportAngularJSApp.controller('TicketsController', function($scope, TicketsFactory, StatusesFactory) {

  $scope.statuses = StatusesFactory.getStatuses();

  $scope.tickets = null;
  $scope.populateTickets = function() {
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
      $scope.tickets = tickets;
    });
  }

  $scope.getTickets = function(status) {
    if ($scope.tickets == null) return [];
    return $.grep($scope.tickets, function(ticket) {
      return (ticket.status.name == status.name);
    });
  }

  $scope.countTickets = function() {
    if ($scope.tickets == null) return 0;
    return $scope.tickets.length;
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