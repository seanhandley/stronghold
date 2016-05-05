$(document).ready(function() {
  $("#project").chained("#organization");
  $('a.toggle_line_entry').click(function(e) {
    e.preventDefault();
    if ($(this).text().charAt(0) == "+") {
      $(this).text("- " + $(this).text().substring(1));
      $("." + $(this).data('id')).removeClass('hide');
    } else {
      $(this).text("+ " + $(this).text().substring(1));
      $("." + $(this).data('id')).addClass('hide');
    }
  });
  $('a.toggle_line_entry').click();

  $('.select-organizations').select2();
});
