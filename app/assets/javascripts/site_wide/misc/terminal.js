function exportTerminalBuffer() {
  var output = $(".terminal").terminal().get_output();
  output = output.split("[;white;black]").join("");
  output = output.split("[gb;#00AA00;black]").join("");
  output = output.split("[gb;#00aaff;black]").join("");
  output = output.split("[gb;#609AE9;;black]").join("");
  output = output.split("[;;;error]").join("");
  output = output.split("[;;;error]").join("");
  output = output.split("&nbsp;").join(" ");
  output = output.split("openstack)]").join("openstack)");
  res = [];
  $.map(output.split("\n"), function(e) {
    s = e.replace(/^\[/,'').replace(/\]$/,'');
    if(s != "") {
      res.push(s);
    }
  });
  
  res = res.join("\n");
  res = res.split("&#91;").join("[");
  res = res.split("&#93;").join("]");
  return res;
}

function saveTerminalOutput(filename, text) {
  var pom = document.createElement('a');
  pom.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
  pom.setAttribute('download', filename);

  if (document.createEvent) {
    var event = document.createEvent('MouseEvents');
    event.initEvent('click', true, true);
    pom.dispatchEvent(event);
  }
  else {
    pom.click();
  }
}

function setPromptProperties() {
  $(".terminal textarea").attr("autocomplete", "off");
  $(".terminal textarea").attr("autocorrect", "off");
  $(".terminal textarea").attr("autocapitalize", "off");
  $(".terminal textarea").attr("spellcheck", "false");
}
