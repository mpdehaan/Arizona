#!/usr/bin/perl

use strict;
use warnings;

use Acme::Engine::Handler;  
use Acme::Engine::Templar;
use Acme::Controllers;
use Arizona::Err::InternalError;
use Dancer;
use MIME::Types;


print STDERR "Demo web page at: http://127.0.0.1:3000/Page/Calculator/display\n";


logger 'console';            # effectively disable Dancer's custom logging as we never call it
#set log         => 'error';  # " " 
#set show_errors => 0;        # performance hog, and we do this at a higher level anyway
#set traces      => 0;        # " "
set log         => 'warn';
set show_errors => 1;
set traces      => 1;


# routes for all view layer and REST API methods are all plugin based.
# serve the contents at the given plugin location.  If a different content type is required, 
# use the ":filename" variant below to force the mimetype to whatever you want.
any ['get','post'] => '/:category/:noun/:verb' => sub {
    my $handler = Acme::Engine::Handler->new(
        templar       => Acme::Engine::Templar->new(),
        category      => params->{category},
        noun          => params->{noun},
        verb          => params->{verb},
        is_rest       => params->{category} eq 'Rest',
        request       => request(),
        default_error => Arizona::Err::InternalError->new(),
    );
    my $content_type = (params->{category} eq 'Rest') ? 'text/plain' : 'text/html';
    content_type($content_type);
    return $handler->dynamic_call();
};

# this is a small variation on our one-and-only (two and only!) route that allows specifying
# the filename for things that are downloadable.
any ['get','post'] => '/:category/:noun/:verb/:filename' => sub {
    my $handler = Acme::Engine::Handler->new(
        templar       => Acme::Engine::Templar->new(),
        category      => params->{category},
        noun          => params->{noun},
        verb          => params->{verb},
        is_rest       => params->{category} eq 'Rest',
        request       => request(),
        default_error => Arizona::Err::InternalError->new(),
    );
    my @tokens = split( /\./, params->{filename} );
    if (scalar length @tokens) {
        my ($mime_type, $mime_name) = MIME::Types::by_suffix($tokens[-1]);
        content_type($mime_type ? $mime_type : 'text/plain');
    } else {
        content_type('text/plain');
    }
    return $handler->dynamic_call();
};

dance;

