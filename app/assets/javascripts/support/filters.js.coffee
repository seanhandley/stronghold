filters = angular.module("filters", [])

filters.filter "momentDateTime", ->
  (time) ->
    return if !time
    moment(time).calendar()

filters.filter "lowerCaseStart", ->
  (text) ->
    text.charAt(0).toLowerCase() + text.slice(1)

filters.filter "capitalize", ->
  (input, all) ->
    return input.replace /([^\W_]+[^\s-]*) */g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
