# this is just a stub user class, because every call through Arizona must
# either return a user who is logged in (even if just an empty shell of an object)
# or raise an error to de-authenticate it.  Our organizational example
# for Acme-Corp doesn't do anything with this, but this can have as much or as
# little context as you want.

use MooseX::Declare;

class Acme::Model::User {
    
    has name => (isa => 'Str', is => 'rw');

}
