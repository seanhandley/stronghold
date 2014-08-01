@Ticket = (reference = "ST-X", title = "Some Ticket", description = "", status = null, email = "nobody@datacentred.co.uk", comments = []) ->
  this.reference = reference
  this.title = title
  this.description = description
  this.status = status
  this.email = email
  this.comments = comments
  this

@Ticket.prototype.changeStatus = () ->
  this.status = status
  this