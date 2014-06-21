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

states = {}

toggleButtonState = (input, state) ->
  states[input] = state
  for _, value of states
    if value != 'has-success'
      $('#inviteUser input#submit').attr('disabled', 'disabled')
      return false
  $('#inviteUser input#submit').removeAttr('disabled')

$ ->
  $('.role-permission').click (e) ->
    $(e.currentTarget).parents('form').submit()

  $('.nav-tab a').click (e) ->
    e.preventDefault()
    $(this).tab('show')

  $('div.panel-heading').click (e) ->
    el = $(this).find("a[data-toggle='collapse']").attr('href')
    $(el).collapse('toggle')

  $('.select-roles').select2();

  $('#inviteUser #invite_email').keyup (e) ->
    state = validateEmail($(this))
    toggleErrorState($(this).closest('.input-group'), state)
    toggleButtonState('invite_email', state);
  $('#inviteUser #invite_email').keyup()

  $('#inviteUser select#invite_roles').change (e) ->
    state = validateRoles($(this))
    toggleErrorState($(this).closest('.input-group'), state)
    toggleButtonState('invite_roles', state);
  $('#inviteUser select#invite_roles').change()
