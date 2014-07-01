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
      "jira_statuses": ['To Do', 'In Progress'],
      "primary_jira_status": 0
    },
    {
      "name": "Closed",
      "color": "#CC0000",
      "jira_statuses": ['Done'],
      "primary_jira_status": 0
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
            return ($.inArray(ticket.attrs.fields.status.name, status.jira_statuses) >= 0);
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