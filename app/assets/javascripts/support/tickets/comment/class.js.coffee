@Comment = (person = new Person(), content = "", time = moment()) ->
  this.person = person
  this.content = content
  console.log(this.content)
  this.time = time
  this