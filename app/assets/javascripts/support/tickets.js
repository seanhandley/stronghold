$(window).load(function () {

  $.extend(window, Routes);

  $.ajax({
    url: Routes.support_api_tickets_path(),
    cache: false
  }).done(
    function(json) {
      var tickets = [];
      console.log(json);
      $.each(json, function (id, jsonElement) {
        attrs = jsonElement.attrs;
        key = attrs.key;
        fields = attrs.fields;
        tickets.push('<li>' + key + '</li>');
      });
      $("#tester").html(tickets.join(''));
    }
  );

});