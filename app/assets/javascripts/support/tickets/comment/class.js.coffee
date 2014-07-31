@Comment = (person = new Person(), content = "", time = moment()) ->
  this.person = person
  this.content = content
  this.time = time
  return

@Comment.prototype.printTime = () ->
  return this.time.format("dddd, MMMM Do YYYY")