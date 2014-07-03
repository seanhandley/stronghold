function Status(name, color) {
  this.name = name;
  this.color = color;
  this.jira_statuses = [];
  this.primary_jira_status = 0;
}

Status.prototype.addJiraStatus = function(jira_status) {
  this.jira_statuses.push(jira_status);
}