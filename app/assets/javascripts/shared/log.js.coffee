window.log = ->
  log.history = log.history or [] # store logs to an array for reference
  log.history.push arguments_
  console.log Array::slice.call(arguments_) if @console
  return