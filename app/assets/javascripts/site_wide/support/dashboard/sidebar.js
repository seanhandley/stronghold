$("#sidebar-toggle").click(function(e) {
        e.preventDefault();
        $("#wrapper").toggleClass("active");
        $("#sidebar-toggle").toggleClass("fa-angle-double-left fa-angle-double-right");
});
