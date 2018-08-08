function onlyShow(className) {
    $("ul.build-tutorial").hide();
    $("ul.build-new").hide();
    $("ul.build-existing").hide();
    if (className) {
        $("ul." + className).show();
    }
}

$( document ).ready(function() {
    var currentPath = $(location).attr('pathname');

    // add active class to the subnav link based on the current page
    var activeLink = $(".content-nav a").filter(function(i, link) {
      return(link.pathname == currentPath);
    });
    activeLink.addClass("active");

    // allows use to use arrow keys to move back and forward through the docs
    var keymap = {};

    // LEFT
    keymap[ 37 ] = "#prev";
    // RIGHT
    keymap[ 39 ] = "#next";

    $( document ).on( "keyup", function(event) {
        var href,
            selector = keymap[ event.which ];
        // if the key pressed was in our map, check for the href
        if ( selector ) {
            href = $( selector ).attr( "href" );
            if ( href ) {
                // navigate where the link points
                window.location = href;
            }
        }
    });
});
