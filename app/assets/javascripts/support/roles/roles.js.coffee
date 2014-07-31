validateEmail = (e) ->
  email = e.val() || ''
  if email.length > 0
    if email.match(/.+@.+\..+/) == null
      return 'has-error'
    else
      return 'has-success'
  else
    return 'has-warning'
  return false

validateRoles = (e) ->
  roles = e.val() || ''
  if roles.length == 0
    return 'has-warning'
  else
    return 'has-success'

toggleErrorState = (e, state) ->
  e.removeClass('has-success')
  e.removeClass('has-error')
  e.removeClass('has-warning')
  e.addClass(state)

$ ->
  $('.role-permission').click (e) ->
    $(e.currentTarget).parents('form').submit()

  $('.nav-tab a').click (e) ->
    e.preventDefault()
    $(this).tab('show')

  $('a.toggle-panel').click (e) ->
    el = $(this).attr('href')
    $(el).collapse('toggle')

  $.each $('a.toggle-panel'), (e) ->
    $($(this).attr('href')).on 'hidden.bs.collapse', () ->
      $(this).closest('.panel').find('i.fa.fa-angle-double-up').addClass('hide')
      $(this).closest('.panel').find('i.fa.fa-angle-double-down').removeClass('hide')

    $($(this).attr('href')).on 'shown.bs.collapse', () ->
      $(this).closest('.panel').find('i.fa.fa-angle-double-down').addClass('hide')
      $(this).closest('.panel').find('i.fa.fa-angle-double-up').removeClass('hide')

  $('#invite_role_ids').select2();
  $('.select-user').select2();

  $('#inviteUser #invite_email').keyup (e) ->
    state = validateEmail($(this))
    toggleErrorState($(this).closest('.input-group'), state)
  $('#inviteUser #invite_email').keyup()

  $('#inviteUser select#invite_role_ids').change (e) ->
    state = validateRoles($(this))
    toggleErrorState($(this).closest('.input-group'), state)
  $('#inviteUser select#invite_role_ids').change()

  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    window.history.replaceState('', '', 'roles?tab=' + $(e.target).data('name'))

  $('.user-images span.image').tooltip({})