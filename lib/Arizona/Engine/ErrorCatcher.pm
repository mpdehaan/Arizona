# Global Error Handler for errors not intercepted elsewhere in code.
# This can be tweaked to return different error pages for different error types.
#
# usage:
#    use Try::Tiny;
#    try {
#       main body of Arizona program
#    } catch {
#       my $error = $_;  # note Try::Tiny quirk, it's not $@
#       return Arizona::Engine::ErrorCatcher->new()->handle($error, $is_rest);
#    }

use MooseX::Declare;

class Arizona::Engine::ErrorCatcher {
  
    use Dancer qw//;
    use Arizona::Engine::Templar;
    use Method::Signatures::Simple name => 'action';

    has templar => (is => 'rw', isa => 'Object');
    has default_error => (is => 'rw', isa => 'Object');

    # Use Arizona::Err::SomeError polymorphically to optionally redirect or draw the specific
    # error template for that error.
    action _object_error($error, $rest) {
        # keep tracebacks reasonable.
        $error->trim();
        # non-rest errors can choose to redirect
        return Dancer::redirect($error->redirect()) if ($error->redirect());
        # always provide the status code
        Dancer::status($error->code());
        # draw page or send JSON response as appropriate
        return ($rest) ? $error->to_json_str() : $self->_render_error($error);
    }

    # stacktraces are somewhat munged by our automagic, restore them!
    action _gen_trace($error) {
        # from top (most recent) of stack to bottom.
        my $buf = "";
        my $count = 0;
        while (my $frame = $error->trace()->next_frame) {
            $buf .= " > " . $frame->package . " " . $frame->filename . " " . $frame->line . "\n";
            last if ++$count > 10;
        }
        return $buf;
    }
 
    # wrapper around error page rendering
    action _render_error($error) {
        my $file = $error->called_by->[1];
        my $line = $error->called_by->[2];
        my $log_str = "ERROR: " . $error->code() . " " . $error->text() ." at $file, line $line\n";
        # don't use warn, we don't want a duplicate line number!
        if ($error->should_log()) {
            # TODO: make BaseError have a $self->log() method.
            warn $log_str;
            print STDERR $self->_gen_trace($error);
        }
        eval {
            return $self->templar()->new(
                template    => $error->template(),
                parameters  => { error => $error },
                request     => undef, # not needed here
                user        => undef,
                title       => $error->caption(),
            )->render_page();
        } or do {
            # an error rendering an error shouldn't happen, except when we're developing
            # a new error page, which is now!
            warn "error rendering page! $@\n";
            return $@;
        };
    }

    # activates the error handler.
    #    $error, error string or object
    #    $rest,  1 if handling an error from a REST call  

    action handle($error, $rest) {
        unless (ref($error) && $error->isa('Arizona::Err::BaseError')) {
            $error = $self->_map_to_object_error($error, $rest);
        } 
        return $self->_object_error($error, $rest);
    };

    # while we can handle errors that are Arizona::Err's directly, non-Arizona errors must
    # be mapped into Arizona:: Errors to be automagically dealt with.

    action _map_to_object_error($error, $rest) {
        
        # mason-like errors respond to message
        if (ref($error) && $error->can('as_brief')) {
            return $self->default_error->new(text => $error->as_brief());
        }

        # error is a flat string
        unless (ref($error)) {
            return $self->default_error->new(text => $error);
        }

        # some other object error, this will be noisy!
        return $self->default_error->new(text => Data::Dumper::Dumper $error); 
    }


}
