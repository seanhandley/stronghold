consoleLog = (message) ->
  if ("console" in window)
    console.log(message)