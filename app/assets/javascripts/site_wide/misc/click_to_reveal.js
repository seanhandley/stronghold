$(document).ready(function() {
  $('.click-to-reveal').one('click', function(){
    $(this).text($(this).data('reveal'));
  });
});