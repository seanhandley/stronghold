$(document).ready(function() {
  $('input#password').strengthMeter('progressBar', {
    container: $('#password-progress-bar-container')
  });

  $('input#password').on("input", function() {
    if($(this).val().length > 0) {
      $('#password-progress-bar-container').show();
    } else {
      $('#password-progress-bar-container').hide();
    }
  });
  $('input#password').trigger('input');
});