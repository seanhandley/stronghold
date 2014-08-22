angular.module("angularJS.filters", []).filter "momentDateTime", [->
  (time) ->
    time.calendar()
]