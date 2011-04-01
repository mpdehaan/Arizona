# Parent class for authorization errors.

use MooseX::Declare;

class Arizona::Err::Forbidden extends Arizona::Err::BaseError {

    use Method::Signatures::Simple name => 'action';

    has code => (is => 'rw', isa => 'Int', default => 403);

    # human readable error type
    action caption() {
       return 'Forbidden';
    }

    # forbidden errors are not currently logged
    action should_log() {
       return 0;
    }

}


