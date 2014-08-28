filters = angular.module("filters", [])

filters.filter "momentDateTime", ->
  (time) ->
    return if !time
    moment(time).calendar()

filters.filter "lowerCaseStart", ->
  (text) ->
    text.charAt(0).toLowerCase() + text.slice(1)