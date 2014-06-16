$(window).load(function () {

  $.extend(window, Routes);

  $.ajax({
    url: Routes.support_api_tickets_path(),
    cache: false
  }).done(
    function(json) {
      var tickets = [];
      $.each(json, function (id, jsonElement) {
        tickets.push('<li>' + jsonElement.attrs.key + '</li>');
      });
      tickets = tickets.join('');
      $("#tester").html(tickets);
    }
  );

});