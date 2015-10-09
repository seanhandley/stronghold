filters = angular.module("filters", [])

filters.filter "momentDateTime", ->
  (time) ->
    return if !time
    moment.locale 'en', {
        'calendar' : {
            'lastDay' : 'Do MMMM YYYY',
            'sameDay' : 'h:mmA',
            'nextDay' : 'Do MMMM YYYY',
            'lastWeek' : 'Do MMMM YYYY',
            'nextWeek' : 'Do MMMM YYYY',
            'sameElse' : 'Do MMMM YYYY'
       }
    }
    
    moment(time).calendar()

filters.filter "lowerCaseStart", ->
  (text) ->
    text.charAt(0).toLowerCase() + text.slice(1)

filters.filter "capitalize", ->
  (input, all) ->
    return input.replace /([^\W_]+[^\s-]*) */g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
