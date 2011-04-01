use MooseX::Declare;

class Arizona::Err::InternalError extends Arizona::Err::BaseError {

   has text => (isa => 'Str', is => 'rw', default => '');

}
