$(document).ready(function() {
  $('#cc-details').submit(function(event) {
    var $form = $(this);

    $form.find('button').prop('disabled', true);

    Stripe.card.createToken($form, stripeResponseHandler);

    return false;
  });
});

function stripeResponseHandler(status, response) {
  var $form = $('#cc-details');

  if (response.error) {
    // Show the errors on the form
    var $div = $("<div id='flash'></div>");
    $div.append($("<p>" + response.error.message + "</p>").addClass('error'));
    $form.find('#flashes').append($div)
    console.log(response.error.message)
    $form.find('button').prop('disabled', false);
  } else {
    // response contains id and card, which contains additional card details
    var token = response.id;
    // Insert the token into the form so it gets submitted to the server
    $form.append($('<input type="hidden" name="stripe_token" />').val(token));
    // Stop submission of details to server
    $form.find('input:not(:hidden)').prop('disabled', true);
    // and submit
    $form.get(0).submit();
  }
};