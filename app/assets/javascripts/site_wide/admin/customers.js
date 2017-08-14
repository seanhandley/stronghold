$(document).ready(function() {
  if(typeof($('html').data('searchable-models')) != 'undefined') {
    $('.customer-search').select2({
      allowClear: true,
      placeholder: "What are you looking for?",
      ajax: {
        url: "/admin/searcher",
        dataType: "json",
        quietMillis: 250,
        data: function(term, page) {
          return {
            q: term
          };
        },
        results: function(data, page) {
          return {
            results: data.matches.map(function(item) {
              return {
                id: item.id,
                text: item.display_name,
                category: item.category,
                url: item.url
              };
            })
          };
        },
        cache: true
      },
      formatResult: function(object, container, query) {
        return object.text + " <span style='float: right'><strong>" + object.category + "</strong></span>";
      }
    });
    $('.customer-search').on('change', function(item) {
      $('#loading-overlay').removeClass('hide');
      document.location.href = item.added.url;
    });
  };

  $('#state-dropdown').on('change', function(e) {
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
      e.preventDefault();
    }
  });

  $('#q').focus();

  $.each(["#toggle-bill-automatically", "#toggle-paying", "#toggle-account", "#toggle-test"], function (i, e) {
    $(e).on('change', function() {
      if(confirm('Are you sure?')) {
        $(e).closest('form').trigger('submit.rails');
      } else {
        window.location.reload();
      }
    });
  });
  $('#tickets-projects-audits-users-tabs a:first').tab('show');
  $('#pending-invoices-tabs a:first').tab('show');
  $('#finalized-invoices-tabs a:first').tab('show');

  $(".dropdown-menu#invoices li a").click(function(){
    $(this).parents(".btn-group").find('.selection').text($(this).text());
    $(this).parents(".btn-group").find('.selection').val($(this).text());
  });
});
