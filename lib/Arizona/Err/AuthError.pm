# Parent class for all authentication/login errors.  Authorization (Arizona::Err::Forbidden) comes later and is not a subclass.

use MooseX::Declare;

class Arizona::Err::AuthError extends Arizona::Err::BaseError {

   has code => (traits => ['Data'], isa => 'Int', is => 'rw', default => 401);

}

