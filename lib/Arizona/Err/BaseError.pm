# base class for Arizona:: Exceptions
# these can define their own redirection behavior (optional) and error
# templates.   They know what code to return to the browser and can also
# be jsonified for REST returns to javascript code or other API usage.

use MooseX::Declare;

class Arizona::Err::BaseError {

    use Method::Signatures::Simple name => 'action';
    use Devel::StackTrace;

    # for humans, explain the error.  ErrorCatcher will handle tracebacks so this is just about what happened, not where.
    has text => (is => 'rw', isa  => 'Str');

    # what HTTP error code to use?
    has code => (is => 'rw', isa  => 'Int', default => 500);
       
    # set by BUILD, not manually, this allows object exceptions to simply print where they were called from
    has called_by => (is => 'rw', isa => 'ArrayRef');
    has trace     => (is => 'rw', isa => 'Object');

    # constructor.  This just sets up our stack trace info right now.
    action BUILD() {
        my @caller = caller(1);
        # for documentation purposes:
        # my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash) = @caller;
        $self->called_by(\@caller);
        $self->trace(Devel::StackTrace->new());
    }

    # does this error cause a redirect?  Return url string if yes, undef if no.
    action redirect() {
        return undef;
    }

    # what template to use when displaying this error?  Override in subclasses.
    action template() {
        return "/templates/error.tpl"
    }

    # what's the Title of this error?  This is used in HTML pages.
    action caption() {
        return "Error";
    }

    # should the error be logged to the server?
    action should_log() {
        return 1;
    }

    # ensure the traceback is less than 10 or so lines, as any longer than that is less than useful
    # shouldn't have long errors without Carp::Always or other similar also in play
    # so this usually does nothing.
    action trim() {
        $self->text('no error message set') if (!defined $self->text());
        my @lines = split /\n/, $self->text();
        my $result = "";
        foreach my $line (@lines) {
            $result .= $line . "\n";
        }
        return $result;
    }

}
