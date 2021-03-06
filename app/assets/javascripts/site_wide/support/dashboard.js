$(document).ready(function() {
  $('#regenerate-datacentred-credentials').click(function(e) {
    e.preventDefault();
    if (confirm("This can't be undone and any applications/users that use these credentials will be locked out until provided with the new credentials. Are you sure?")) {
      $('#loading-overlay').removeClass('hide');
      $('#show-js-errors').empty();
      $.post('/regenerate_datacentred_api_credentials', {'authenticity_token': AUTH_TOKEN}, function(data) {
        if(data.success) {
          $('#loading-overlay').addClass('hide');
          $('#datacentred-secret-key').empty();
          $('#datacentred-secret-key').append(data.secret_key);
          $('#copy-datacentred-secret-key button').attr('data-clipboard-text', data.secret_key);
          $('#copy-datacentred-secret-key').removeClass('hide');
        } else {
          $('#show-js-errors').append('<div class="alert alert-danger">Failed to generate secret key. Support team has been notified.</div>')
        }
      });
    }
  });
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

  $('#dashboard-tabs a:first').tab('show');

  if(typeof(ion) !== 'undefined') {
    ion.sound({
      sounds: [
        {
          name: "water_droplet"
        }
      ],
      volume: 0.2,
      path: "/sounds/",
      preload: true
    });
  }

  $('#select-organization').change(function() {
    $('#loading-overlay').removeClass('hide');
    $(this).closest('form').submit();
  });
});
