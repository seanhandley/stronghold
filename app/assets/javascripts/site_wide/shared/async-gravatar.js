/*!
 * jQuery async Gravatar
 * https://github.com/llaumgui/jquery-async-gravatar
 *
 * Copyright 2015 Guillaume Kulakowski and other contributors
 * Released under the MIT license
 * https://raw.githubusercontent.com/llaumgui/jquery-async-gravatar/master/LICENSE.txt
 */
( function( $ ) {
    "use strict";

    /**
     * Gravatar object
     */
    $.gravatar = {
        options: {},

        // Default options.
        default_options: {
            size: 64,
            default_img: "mm",
            force_https: false,
            rating: "g",
            attr: {
                hash: "data-gravatar_hash",
                size: "data-gravatar_size",
                rating: "data-gravatar_rating",
                default: "data-gravatar_default"
            }
        },

        // HTTP & HTTPS URLs.
        urls: {
            http: "http://www.gravatar.com",
            https: "https://secure.gravatar.com"
        }
    };

    $.extend( $.gravatar, {
        /**
         * Init
         */
        init: function( arg ) {

            // Reset options for multiple call.
            $.gravatar.reset();

            // Extends Gravatar with arguments.
            if ( arg ) {
                $.extend( $.gravatar.options, arg );
            }

            // Check protocol.
            if ( $.gravatar.options.force_https === true || "https:" === document.location.protocol ) {
                $.gravatar.url = $.gravatar.urls.https;
            } else {
                $.gravatar.url = $.gravatar.urls.http;
            }
        },

        /**
         * Reset to use multiple calls
         */
        reset: function() {

            // Reset options for multiple call.
            $.extend( $.gravatar.options, $.gravatar.default_options );
        }
    } );

    /**
     * asyncGravatar jQuery plugin.
     */
    $.fn.asyncGravatar = function( arg )  {

        // Init.
        $.gravatar.init( arg );

        this.each( function() {
            if ( $( this ).attr( $.gravatar.options.attr.hash ) ) {
                var hash = $( this ).attr( $.gravatar.options.attr.hash ),

                    // Allow to override with data attributs ("data-").
                    size = ( $( this ).attr( $.gravatar.options.attr.size ) ? $( this ).attr( $.gravatar.options.attr.size ) : $.gravatar.options.size ),
                    rating = ( $( this ).attr( $.gravatar.options.attr.rating ) ? $( this ).attr( $.gravatar.options.attr.rating ) : $.gravatar.options.rating ),
                    default_img = ( $( this ).attr( $.gravatar.options.attr.default ) ? $( this ).attr( $.gravatar.options.attr.default ) : $.gravatar.options.default_img ),
                    src = $.gravatar.url + "/avatar/" + encodeURIComponent( hash ) +
                    "?s=" + encodeURIComponent( size ) +
                    "&r=" + encodeURIComponent( rating ) +
                    "&d=" + encodeURIComponent( default_img );

                $( this ).attr( "src", src );
            }
        } );
    };
}( jQuery ) );
