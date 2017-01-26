$(document).ready(function() {
  $.fn.modal.Constructor.prototype.enforceFocus = function() {};
  var clipboard = new Clipboard('.btn-copy');

  clipboard.on('success', function(e) {
      $(e.trigger).data('title', "Copied!");
      $(e.trigger).tooltip('show');
      setTimeout(function() {
        $('.btn-copy').tooltip('hide')
      }, 1600);

      e.clearSelection();
  });

  clipboard.on('error', function(e) {
    $(e.trigger).data('title', "Press Ctrl+C to copy");
    $(e.trigger).tooltip('show');
    setTimeout(function() {
      $('.btn-copy').tooltip('hide')
    }, 1600);
  });
});