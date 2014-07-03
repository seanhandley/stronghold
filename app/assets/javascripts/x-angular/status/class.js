function Ticket(reference, title, description, status, person, comments) {
  this.reference = (reference || "ST-X");
  this.title = (title || "Some Ticket");
  this.description = (description || "Bacon ipsum dolor sit amet turkey salami meatball tail, boudin beef pig pastrami bresaola capicola kevin spare ribs rump swine.");
  this.status = (status || null);
  this.person = (person || new Person());
  this.comments = (comments || []);
}

Ticket.prototype.changeStatus = function(status) {
  this.status = (status || null);
}