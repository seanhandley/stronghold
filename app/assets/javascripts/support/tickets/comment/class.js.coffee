@Comment = (email = "nobody@datacentred.co.uk", content = "", time = moment()) ->
  this.email = email
  this.content = content
  console.log(this.content)
  this.time = time
  this