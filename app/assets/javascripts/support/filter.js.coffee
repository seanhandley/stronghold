angular.module("angularJS.filters", []).filter "momentDateTime", [->
  (time) ->
    time.format("dddd, MMMM Do YYYY")
]