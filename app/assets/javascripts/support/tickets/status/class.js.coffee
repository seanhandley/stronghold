@TicketStatus = (name) ->
  this.name = name
  this.jira_statuses = []
  this.primary_jira_status = 0
  this.active = false
  this

@TicketStatus.prototype.addJiraStatus = (jira_status) ->
  this.jira_statuses.push(jira_status)
  this