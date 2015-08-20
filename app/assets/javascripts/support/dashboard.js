$(document).ready(function() {
  $('#regenerate-ceph-credentials').click(function(e) {
    e.preventDefault();
    if (confirm("This can't be undone and any applications/users that use these credentials will be locked out until provided with the new credentials. Are you sure?")) {
      $('#loading-overlay').removeClass('hide');
      $.post('/regenerate_ceph_credentials', function(data) {
        if(data.success) {
          $('#loading-overlay').addClass('hide');
          $('#ceph-access-key').text(data.credentials.access);
          $('#ceph-secret-key').empty();
          $('#ceph-secret-key').append(data.credentials.secret);
          $('#ceph-secret-key').data('reveal', data.credentials.secret);
        } else {
          alert(data.message);
        }
      });
    }
  });
});