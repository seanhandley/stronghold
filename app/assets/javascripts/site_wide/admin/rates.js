$(document).ready(function() {
  $(".billing_rate_edit").on("input", function() {
    $('form *').removeClass('withError')
    $('.successMessage').remove();
  });
});
