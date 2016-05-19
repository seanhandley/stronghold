$(document).ready(function() {
  if(typeof($('html').data('searchable-models')) != 'undefined') {
    $('.customer-search').soulmate({
      url: '/admin/sm/search',
      types: $('html').data('searchable-models').split(" "),
      renderCallback: function(term, data, type) {
        return term;
      },
      selectCallback: function(term, data, type) {
        document.location.href = data['url'];
      },
      minQueryLength: 2,
      maxResults: 5
    });
  };

  $('#state-dropdown').on('change', function() {
    id = $(this).data('organization');
    $.ajax({
      url: '/admin/customers/' + id,
      type: 'put',
      data: {"organization[state]": $(this).val(), "organization[id]": id}
    });
  });
});
