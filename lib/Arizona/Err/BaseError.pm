# base class for Arizona:: Exceptions

use MooseX::Declare;

class Arizona::Err::BaseError {

    use Method::Signatures::Simple name => 'action';
    use Devel::StackTrace;
    
    has text => (is => 'rw', isa  => 'Str');
    has code => (is => 'rw', isa  => 'Int', default => 500);
       
    # set by BUILD, not manually, this allows object exceptions to simply print where they were called from
    has called_by => (is => 'rw', isa => 'ArrayRef');
    has trace     => (is => 'rw', isa => 'Object');

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
    # FIXME: do we need this, shouldn't have long errors without Carp::Always or other similar also in play
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
