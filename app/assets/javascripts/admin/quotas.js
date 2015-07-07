$(document).ready(function(){
  $('form.admin_quota_form input').change(function(){
    $('form.admin_quota_form').submit();
  });
});