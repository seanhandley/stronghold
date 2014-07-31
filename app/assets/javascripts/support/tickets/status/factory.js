supportAngularJSApp.factory('StatusesFactory', function() {
  return {
    getStatuses: function() {
      //"Open" Status
      var openStatus = new Status();
      openStatus.name = "Open";
      openStatus.color = "#00CC00";
      openStatus.addJiraStatus('To Do');
      openStatus.addJiraStatus('In Progress');
      //"Closed" Status
      var closedStatus = new Status();
      closedStatus.name = "Closed";
      closedStatus.color = "#CC0000";
      closedStatus.addJiraStatus('Done');
      //Return Statuses
      var statuses = [openStatus, closedStatus];
      return statuses;
    }
  };
});