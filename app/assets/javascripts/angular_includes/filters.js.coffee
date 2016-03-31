filters = angular.module("filters", [])

filters.filter "momentDateTime", -> # used twice in _ticket.html
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

filters.filter "lowerCaseStart", -> # never used
  (text) ->
    text.charAt(0).toLowerCase() + text.slice(1)

filters.filter "capitalize", -> # never used
  (input, all) ->
    return input.replace /([^\W_]+[^\s-]*) */g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
