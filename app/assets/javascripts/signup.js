$(document).ready(function() {
  $('#cc-details').submit(function(event) {
    var $form = $(this);

    $form.find('input[type=submit]').prop('disabled', true);

    Stripe.card.createToken($form, stripeResponseHandler);

    return false;
  });

  var card = new Card({form: 'form',container: '#card-display',
    formSelectors: {
        numberInput: 'input#card_number',
        expiryInput: 'input#expiry',
        cvcInput: 'input#cvc',
        nameInput: 'input#name'
    },
    width: 180
  });

  $('#expiry').change(function() {
    month = $(this).val().split('/')[0].trim();
    year = $(this).val().split('/')[1].trim().substring(2);
    $('#expiry_month').val(month);
    $('#expiry_year').val(year);
  })
});

function stripeResponseHandler(status, response) {
  var $form = $('#cc-details');

  if (response.error) {
    showError(response.error.message);
    $form.find('input[type=submit]').prop('disabled', false);
  } else {
    // response contains id and card, which contains additional card details
    var token = response.id;
    // Insert the token into the form so it gets submitted to the server
    $form.append($('<input type="hidden" name="stripe_token" />').val(token));

    var uuid = $form.find('#signup_uuid').val();
    // Check the address is valid via precheck
    $.post('/precheck?stripe_token=' + token + '&signup_uuid=' + uuid, function(data) {
      if(data.success) {
        // Stop submission of details to server
        $form.find('input:not(:hidden)').prop('disabled', true);
        // and submit
        $form.get(0).submit();
      } else {
        showError(data.message);
      }
    });

  }
};

function showError(message) {
  // Show the errors on the form
  var $form = $('#cc-details');
  var $div = $("<div id='flash'></div>");
  $div.append($("<p>" + message + "</p>").addClass('error'));
  $form.find('#flashes').empty();
  $form.find('#flashes').append($div)
}