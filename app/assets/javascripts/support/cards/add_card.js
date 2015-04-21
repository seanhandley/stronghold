$(document).ready(function() {
  $('#add_new_card').submit(function(event) {
    var $form = $(this);

    $form.find('input[type=submit]').prop('disabled', true);

    Stripe.card.createToken($form, AddCard.stripeResponseHandler);

    return false;
  });
});

var AddCard = {
  stripeResponseHandler: function (status, response) {
    var $form = $('#add_new_card');

    document.body.style.cursor='wait';

    if (response.error) {
      AddCard.showError(response.error.message);
      $form.find('input[type=submit]').prop('disabled', false);
      document.body.style.cursor='default';
    } else {
      // response contains id and card, which contains additional card details
      var token = response.id;
      // Insert the token into the form so it gets submitted to the server
      $form.append($('<input type="hidden" name="stripe_token" />').val(token));
      $form.get(0).submit();
    }
  },

  showError: function (message) {
    // Show the errors on the form
    var $form = $('#add_new_card');
    var $div = $("<div id='flash'></div>");
    $div.append($("<p>" + message + "</p>").addClass('error'));
    $form.find('#flashes').empty();
    $form.find('#flashes').removeClass('hide');
    $form.find('#flashes').append($div)
  }
}