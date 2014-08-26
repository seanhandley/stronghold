angular.module("angularJS.filters", []).filter "momentDateTime", ->
  (time) ->
    return if !time
    moment(time).calendar()