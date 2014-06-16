stronghold.factory 'Ticket', ['$resource', ($resource) ->
  $resource '/support/api/tickets/:id', id: '@id'
]