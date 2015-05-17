$ ->
  # If page is not public, set timeout to auto log out
  if $('body.public-page').length == 0
    setTimeout (() ->
      window.location.reload()
    ), 605000