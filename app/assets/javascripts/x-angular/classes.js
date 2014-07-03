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
  return this.time.format("dddd, MMMM Do YYYY");
}