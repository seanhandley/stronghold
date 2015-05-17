$(document).ready(function() {
  $('.click-to-reveal').on('click', function(){
    $(this).text($(this).data('reveal'));
  });
});