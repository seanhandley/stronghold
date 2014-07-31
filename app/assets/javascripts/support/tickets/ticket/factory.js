supportAngularJSApp.factory('TicketsFactory', function($http) {
  return {
    getTickets: function() {

      var successHandler = function(response) {

        if (response.statusText != "OK") return null;

        var tickets = [];
        angular.forEach(response.data, function(responseTicket, index){
          //Fresh Ticket
          var newTicket = new Ticket();

          //Current Backend Alignment
          newTicket.jira_status = responseTicket.attrs.fields.status.name;
          newTicket.reference = responseTicket.attrs.key;
          newTicket.title = responseTicket.attrs.fields.summary;
          newTicket.description = responseTicket.attrs.fields.description;

          //Comment Simulation
          newTicket.comments = [
            new Comment(null, "This rocks!", moment([2013, 11, 25])),
            new Comment(null, "This sucks.", moment([2013, 11, 27])),
          ];

          //Debug
          console.log(newTicket.comments);

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