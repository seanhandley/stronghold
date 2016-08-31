$(document).ready(function() {
  if($('.openstack-client-terminal').length) {
    $('#saveTerminal').click(function(e) {
      saveTerminalOutput("openstack_client_" + new Date().toISOString() + ".txt", exportTerminalBuffer());
      e.preventDefault();
    });
    $('#clearTerminal').click(function(e) {
      $('.openstack-client-terminal').terminal().clear();
      e.preventDefault();
    });
    $('select#projects').change(function() {
      console.log($(this).val());
      $('.openstack-client-terminal').terminal().echo(new String("*** Project changed to " + $(this).val() + ' ***'))
    });
    $('.openstack-client-terminal').scroll(function() {
      $('.term-buttons').css('top', $(this).scrollTop());
    });
    $('.openstack-client-terminal').terminal(function(command, term) {
      if (command !== '') {
        term.pause();
        $('#command-processing').removeClass('hide');
        project = $('select#projects').val();
        $.ajax({
          type: "POST",
          contentType: "application/json;",
          url: '/account/terminal_command.js',
          dataType: 'json',
          data: JSON.stringify({command: command, project: project}),
          success: function (data, textStatus, xhr) {
            term.resume();
            $('#command-processing').addClass('hide');
            msg = new String(data.message);
            if(data.success) {
              term.echo(msg);
            } else {
              term.error(msg);
            }
          },
          error: function (e, textStatus, xhr) {
            if(e.status == 302) {
              term.error('You are no longer authenticated. Please log in and try again.');
              setTimeout(function(){ window.location.replace('/terminal') }, 2000);
            } else if(e.status == 0) {
              term.error("Failed to connect to server. Are you connected to the Internet?");
            } else {
              term.error('An error prevented this command being executed. Server response: "' + e.status + ': ' + e.statusText + '"');
            }
            term.resume();
            $('#command-processing').addClass('hide');
          }
        });
      } else {
         term.echo('');
      }
    }, {
      greetings: "[[gb;#609AE9;;black]\
     ____        __        _____            __                __\n \
   / __ \\____ _/ /_____ _/ ___/___  ____  / /_________  ____/ /\n \
  / / / / __ `/ __/ __ `/ /   / _ \\/ __ \\/ __/ ___/ _ \\/ __  / \n \
 / /_/ / /_/ / /_/ /_/ / /___/  __/ / / / /_/ /  /  __/ /_/ /  \n \
/_____/\\__,_/\\__/\\__,_/\\____/\\___/_/ /_/\\__/_/   \\___/\\__,_/   \n \
                                                               \n \
Welcome to the your terminal. Type 'help' for usage info.]\n\n",
      name: 'OpenStack Client',
      height: '60vh',
      width: '100%',
      prompt: "[[gb;#00AA00;black](openstack)] ",
      tabcompletion: true,
      completion: function(terminal, string, callback) {
        $.getJSON('/account/terminal_tab_complete.js', function(data) {
          choices = $.map(data, function(e) {
            if(e.indexOf($('.openstack-client-terminal').terminal().get_command()) != -1) {
              return e;
            }
          });
          if(choices.length == 1) {
            $('.openstack-client-terminal').terminal().set_command(choices[0]);
          } else {
            callback(choices);
          }
        });
      },
      exit: false,
      clear: false
    });
  }
  $('.openstack-client-terminal').removeClass('hide');
  setInterval(function() {
    setPromptProperties();
  }, 1000);
  $(".openstack-client-terminal").click();
});
