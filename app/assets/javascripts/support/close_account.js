$(document).ready(function() {
  $('.modal.fade#closeAccount #submit').prop('disabled', true);
  $('.modal.fade#closeAccount #password').on('input', function() {
    $.post('/reauthorise', {'password': $(this).val()}, function(data) {
      if(data.success) {
        $('.modal.fade#closeAccount #submit').prop('disabled', false);
      } else {
        $('.modal.fade#closeAccount #submit').prop('disabled', true);
      }
    });
  });
  $('.modal.fade#closeAccount #password').trigger('input');
});