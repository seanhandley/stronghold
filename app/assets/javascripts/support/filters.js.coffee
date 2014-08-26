# angular.module("angularJS.filters", []).filter "momentDateTime", [->
#   (time) ->
#     console.log(time)
#     time.calendar()
# ]

angular.module("angularJS.filters", []).filter "momentDateTime", ->
  (time) ->
    return if !time
    moment(time).calendar()