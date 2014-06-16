stronghold.controller 'TicketsCtrl', ['$scope', 'Ticket', ($scope, Ticket) ->
  $scope.tickets = Ticket.query()
]