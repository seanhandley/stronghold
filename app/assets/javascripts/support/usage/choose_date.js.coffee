$ ->
  $('#month_year').selectpicker()
  $('#month_year').on "change", () ->
    location.href = $(this).val()