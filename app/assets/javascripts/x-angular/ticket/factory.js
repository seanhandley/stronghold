stronghold.factory('TicketsFactory', function($http) {
  return {
    getTickets: function() {

      var successHandler = function(response) {
        if (response.statusText != "OK") return null;
        var tickets = [];
        $.each(response.data, function(index, rubyTicket) {

          //Debug
          //console.log(rubyTicket);

          //Fresh Ticket
          var newTicket = new Ticket();

          //Current Backend Bodges
          newTicket.jira_status = rubyTicket.attrs.fields.status.name;
          newTicket.reference = rubyTicket.attrs.key;
          newTicket.title = rubyTicket.attrs.fields.summary;
          newTicket.description = rubyTicket.attrs.fields.description;

          //Comment Simulation
          newTicket.comments = [
            new Comment(null, "This rocks!", moment([2013, 11, 25])),
            new Comment(null, "This sucks.", moment([2013, 11, 27]))
          ];

          //Debug
          //console.log(newTicket);

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