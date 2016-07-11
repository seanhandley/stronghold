$(document).ready(function() {
  if(typeof($('html').data('searchable-models')) != 'undefined') {
    $('.customer-search').soulmate({
      url: '/admin/sm/search',
      types: $('html').data('searchable-models').split(" "),
      renderCallback: function(term, data, type) {
        return term + ' (' + data.reporting_code + ')';
      },
      selectCallback: function(term, data, type) {
        $('#loading-overlay').removeClass('hide');
        document.location.href = data['url'];
      },
      minQueryLength: 2,
      maxResults: 5
    });
  };

  $('#state-dropdown').on('change', function() {
    new_state = $(this).val();
    id = $(this).data('organization');
    name = $(this).data('organization-name');
    if(new_state.length > 0) {
      if(confirm("Are you sure you wish to change " + name + "'s state to " + new_state + "?")) {
        $.ajax({
          url: '/admin/customers/' + id,
          type: 'put',
          data: {"organization[state]": $(this).val(), "organization[id]": id}
        });
        $('#loading-overlay').removeClass('hide');
      } else {
        $(this).val('')
      }
    }
  });

  $('#q').focus();

  $('#toggle-paying').on('change', function() {
    $('#paying_form').trigger('submit.rails');
  });

  $('#toggle-account').on('change', function() {
    $('#account_form').trigger('submit.rails');
  });
});
