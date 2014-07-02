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

function Status(name, color) {
  this.name = name;
  this.color = color;
  this.jira_statuses = [];
  this.primary_jira_status = 0;
}

Status.prototype.addJiraStatus = function(jira_status) {
  this.jira_statuses.push(jira_status);
}

function Person(name, picture) {
  this.name = (name || "Somebody");
  this.picture = (picture || "http://jadaradix.com/binaries/lego-hair.jpg");
}

function Comment(person, content, time) {
  this.person = (person || new Person());
  this.content = (content || "Bacon ipsum dolor sit amet turkey salami meatball tail, boudin beef pig pastrami bresaola capicola kevin spare ribs rump swine.");
  this.time = (time || moment());
}

Comment.prototype.printTime = function() {
  console.log(this.time);
  return this.time.format("dddd, MMMM Do YYYY");
}