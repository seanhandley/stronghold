$ ->
  $('#month_year').selectpicker()
  $('#month_year').removeClass('hide')
  $('.bootstrap-select').removeClass('hide')
  $('#month_year').on "change", () ->
    $('#loading-overlay').removeClass('hide');
    location.href = $(this).val()