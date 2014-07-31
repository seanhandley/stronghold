@Ticket = (reference = "ST-X", title = "Some Ticket", description = "", status = null, person = new Person(), comments = []) ->
  this.reference = reference
  this.title = title
  this.description = description
  this.status = status
  this.person = person
  this.comments = comments
  return

@Ticket.prototype.changeStatus = () ->
  this.status = status
  return