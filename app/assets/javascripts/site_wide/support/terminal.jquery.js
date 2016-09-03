$(document).ready(function() {
  if($('.openstack-client-terminal').length) {
    $('select#projects').change(function() {
      console.log($(this).val());
      $('.openstack-client-terminal').terminal().echo(new String("*** Project changed to " + $(this).val() + ' ***'))
    });
    $('.openstack-client-terminal').scroll(function() {
      $('.term-buttons').css('top', $(this).scrollTop());
    });
    $('.openstack-client-terminal').terminal(function(command, term) {
      if (command !== '') {
        if(command == "clear") {
          $(".terminal").terminal().clear();
          $(".terminal").terminal().reset();
        } else if(command == "nyan") {
          nyanPlay(term);
        } else if(command == "save") {
          saveTerminalOutput("openstack_client_" + new Date().toISOString() + ".txt", exportTerminalBuffer());
        } else {
          term.pause();
          showCog(term);
          project = $('select#projects').val();
          $.ajax({
            type: "POST",
            contentType: "application/json;",
            url: '/account/terminal_command.js',
            dataType: 'json',
            data: JSON.stringify({command: command, project: project}),
            success: function (data, textStatus, xhr) {
              term.resume();
              msg = new String(data.message);
              if(data.success) {
                if(command == 'help' || command == 'commands') {
                  term.clear();
                }
                term.echo(msg);
                if(command == 'help' || command == 'commands') {
                  term.scroll(-10000);
                }
              } else {
                if(data.message.indexOf("--os-token: expected one argument") !== -1) {
                  term.error(new String("You're not currently authenticated in this project. Please log in again and retry."));
                  setTimeout(function(){ window.location.replace('/sign_out') }, 2000);
                } else {
                  term.error(msg);
                }
              }
            },
            error: function (e, textStatus, xhr) {
              if(e.status == 302) {
                term.error('You are no longer authenticated. Please log in and try again.');
                setTimeout(function(){ window.location.replace('/account/terminal') }, 2000);
              } else if(e.status == 0) {
                term.error("Failed to connect to server. Are you connected to the Internet?");
              } else {
                term.error('An error prevented this command being executed. Server response: "' + e.status + ': ' + e.statusText + '"');
              }
              term.resume();
            }
          });
        }
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
Type 'help' for a tutorial or 'commands' for a full reference.]\n",
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
      clear: false,
      onBeforeCommand: function(command) {
        nyanClear();
      },
      onAfterCommand: function(command) {
        hideCog();
      },
      onClear: function(term) {
        nyanClear();
      }
    });
  }
  $('.osx').hide().css('opacity', 1).fadeIn(500).fadeOut(10).fadeIn(10);
  setInterval(function() {
    setPromptProperties();
  }, 1000);
  $(".openstack-client-terminal").click();
});

$(document).keyup(function(e) {
  if (e.keyCode == 27) {
    if($("#terminalShortcuts:visible").length == 0) {
      $('#terminalShortcuts').modal('toggle');
    } else {
      $('.modal-backdrop').remove();
    }
  }
});
