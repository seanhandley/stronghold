window.angularJS = angular.module('angularJS', ['ui.bootstrap', 'filters', 'ngSanitize', 'ngAnimate', 'ui.gravatar'])

window.angularJS.config ["$httpProvider", ($httpProvider) ->
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
]