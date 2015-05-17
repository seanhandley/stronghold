$(document).ready(function() {
  $('.click-to-reveal').on('click', function(){
    var reveal = $(this).data('reveal');
    var text = $(this).html()
    $(this).html(reveal);
    $(this).data({'reveal': text});
  });
});