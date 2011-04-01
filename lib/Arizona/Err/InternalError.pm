use MooseX::Declare;

class Arizona::BaseError::InternalError extends Arizona::Err::BaseError {

   has text => (traits => ['Data'], isa => 'Str', is => 'rw', default => '');

}
