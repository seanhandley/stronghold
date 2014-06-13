$.ajax({
  url: "test.html",
  cache: false
})
.done(function( html ) {
  $( "#results" ).append( html );
});