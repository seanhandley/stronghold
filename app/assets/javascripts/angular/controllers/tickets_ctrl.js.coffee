stronghold.controller 'TicketsCtrl', ['$scope', 'Ticket', ($scope, Ticket) ->
  $scope.tickets_open = Ticket.query()
  $scope.tickets_closed = Ticket.query()
]