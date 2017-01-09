$(document).ready(function() {
  $('#regenerate-ceph-credentials').click(function(e) {
    e.preventDefault();
    if (confirm("This can't be undone and any applications/users that use these credentials will be locked out until provided with the new credentials. Are you sure?")) {
      $('#loading-overlay').removeClass('hide');
      $('#show-js-errors').empty();
      $.post('/regenerate_ceph_credentials', {'authenticity_token': AUTH_TOKEN}, function(data) {
        if(data.success) {
          $('#loading-overlay').addClass('hide');
          $('#ceph-access-key').text(data.credentials.access);
          $('#ceph-secret-key').empty();
          $('#ceph-secret-key').append(data.credentials.secret);
          $('#ceph-secret-key').data('reveal', data.credentials.secret);
        } else {
          $('#show-js-errors').append('<div class="alert alert-danger">Failed to regenerate. Support team has been notified.</div>')
        }
      });
    }
  });
  if($('body').data('controller') == 'support/dashboard' && $('body').data('action') == 'index') {
    $.getJSON('/account', {'authenticity_token': AUTH_TOKEN}, function(data) {
      $('span#instances_active').text(data.instance_count);
      $('span#object-storage').text(data.object_usage + ' GB')
    });
  }
  $('#starburst-close').click(function() {
    $(this).closest('form').submit();
    $('#starburst-announcement').remove();
  });

  $( ".gravatar" ).asyncGravatar( {
    "size": "30",
    "force_https": true
  });

  $('a.limits-collapse').click(function() {
    if ( $(this).next('.accordion-body').hasClass('in') ) {
        $(this).text('Show');
    } else {
        $(this).text('Hide');
    }
  });

  $('#overview-projects-tabs a:first').tab('show');
});
