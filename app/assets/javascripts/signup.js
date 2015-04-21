$(document).ready(function() {
  $('#cc-details').submit(function(event) {
    var $form = $(this);

    $form.find('input[type=submit]').prop('disabled', true);

    Stripe.card.createToken($form, Signup.stripeResponseHandler);

    return false;
  });
  if ("Card" in window) {
    var card = new Card({form: 'form',container: '#card-display',
      formSelectors: {
          numberInput: 'input#card_number',
          expiryInput: 'input#expiry',
          cvcInput: 'input#cvc',
          nameInput: 'input#name'
      }
    });
  }
  $('input#expiry').change(function() {
    month = $(this).val().split('/')[0].trim();
    year = $(this).val().split('/')[1].trim().substring(2);
    $('#expiry_month').val(month);
    $('#expiry_year').val(year);
  });

  $('#lookup-field').setupPostcodeLookup({
    // Add your API key
    api_key: 'ak_i7hlkdrpH82slSRuCcKrSslMyLHQg',
    // Identify your fields with CSS selectors
    output_fields: {
      line_1: '#address_line1',  
      line_2: '#address_line2',         
      post_town: '#address_city',
      postcode: '#postcode'
    },
    input_label: "Post code",
    button_disabled_message: "Checking"
  });

  $('#discount_code').on('input', function() {
    $.post('/voucher_precheck?code=' + $(this).val(), function(data) {
      console.log(data)
      if(data.success) {
        $('#discount_code_message').text(data.message)
        $('#discount_code').closest('.input-group').removeClass('has-error');
        $('#discount_code').closest('.input-group').addClass('has-success');
      } else {
        if($('#discount_code').val().length == 0) {
          $('#discount_code').closest('.input-group').removeClass('has-error');
        } else {
          $('#discount_code_message').text('');
          $('#discount_code').closest('.input-group').addClass('has-error');
        }
      }
    });
  });

});

var Signup = {
  stripeResponseHandler: function (status, response) {
    var $form = $('#cc-details');

    document.body.style.cursor='wait';

    if (response.error) {
      Signup.showError(response.error.message);
      $form.find('input[type=submit]').prop('disabled', false);
      document.body.style.cursor='default';
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
          $form.find('#card_number').prop('disabled', true);
          $form.find('#cvc').prop('disabled', true);
          // and submit
          $form.get(0).submit();
        } else {
          Signup.showError(data.message);
          $form.find('input[type=submit]').prop('disabled', false);
          document.body.style.cursor='default';
        }
      });

    }
  },

  showError: function (message) {
    // Show the errors on the form
    var $form = $('#cc-details');
    var $div = $("<div id='flash'></div>");
    $div.append($("<p>" + message + "</p>").addClass('error'));
    $form.find('#flashes').empty();
    $form.find('#flashes').removeClass('hide');
    $form.find('#flashes').append($div)
  }
}