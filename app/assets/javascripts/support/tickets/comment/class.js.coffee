@Comment = (person = new Person(), content = "", time = moment()) ->
  this.person = person
  this.content = content
  this.time = time
  return this

@Comment.prototype.printTime = () ->
  this.time.format("dddd, MMMM Do YYYY")