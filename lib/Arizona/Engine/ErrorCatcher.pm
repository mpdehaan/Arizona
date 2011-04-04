# Global Error Handler for errors not intercepted elsewhere in code.
# Errors can be subclassed to return different error pages for different error types.
#
# usage:
#    eval {
#       main body of Arizona program
#    or do {
#       my $error = $@;
#       return Arizona::Engine::ErrorCatcher->new()->handle($error, $is_rest);
#    }

use MooseX::Declare;

class Arizona::Engine::ErrorCatcher {
  
    use Dancer qw//;
    use Arizona::Engine::Templar;
    use Method::Signatures::Simple name => 'action';

    # pass in a empty Arizona::Engine::Templar subclass instance so we know how to render the errors.
    has templar => (is => 'rw', isa => 'Object');

    # pass in an empty Arizona::Err subclass for the default error to upconvert string and on Arizona::Err
    # object errors into
    has default_error => (is => 'rw', isa => 'Object');

    # Use Arizona::Err::SomeError polymorphically to optionally redirect or draw the specific
    # error template for that error.
    action _object_error($error, $rest) {
        # keep tracebacks reasonablely short
        # this only really happens when using something like Carp::Always or confess elsewhere.
        $error->trim();
        # non-rest errors can choose to redirect to other pages, support that...
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
        # Err:: subclasses generate a Devel::StackTrace upon BUILD, print it
        while (my $frame = $error->trace()->next_frame) {
            $buf .= " > " . $frame->package . " " . $frame->filename . " " . $frame->line . "\n";
            last if ++$count > 10;
        }
        return $buf;
    }
 
    # wrapper around error page rendering
    action _render_error($error) {

        # log the error if the error thinks it should be logged.
        my $file = $error->called_by->[1];
        my $line = $error->called_by->[2];
        my $log_str = "ERROR: " . $error->code() . " " . $error->text() ." at $file, line $line\n";
        # don't use warn, we don't want a duplicate line number!
        if ($error->should_log()) {
            # TODO: cleanup: make BaseError have a $self->log() method.
            warn $log_str;
            print STDERR $self->_gen_trace($error);
        }
        eval {
            # try to render the error page, if we have an error rendeiring the error we'll log it
            return $self->templar()->new(
                template    => $error->template(),
                parameters  => { error => $error },
                request     => undef, # not needed here
                user        => undef,
                title       => $error->caption(),
            )->render_page();
        } or do {
            # an error rendering an error shouldn't happen.
            warn "error rendering page! $@\n";
            return $@;
        };
    }

    # called in main body of application to trigger the error handler (see USAGE at top)
    #    $error, error string or object
    #    $rest,  1 if handling an error from a REST call  

    action handle($error, $rest) {
        unless (ref($error) && $error->isa('Arizona::Err::BaseError')) {
            # upconvert the error to something we can work with
            $error = $self->_map_to_object_error($error, $rest);
        } 
        return $self->_object_error($error, $rest);
    };

    # while we can handle errors that are Arizona::Err's directly, non-Arizona errors must
    # be mapped into Arizona:: Errors to be automagically dealt with.
    # A good value for default_err is WA::Err::InternalError.

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
