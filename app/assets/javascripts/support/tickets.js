jQuery.extend(window, Routes);
$.ajax({
  url: Routes.support_api_tickets_path(),
  cache: false
}).done(
  function(html) {
    console.log(html);
  }
);