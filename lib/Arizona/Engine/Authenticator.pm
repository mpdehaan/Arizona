# Arizona::Engine::Authenticator
# 
# Authenticates requests.  Called before all other controllers.   
# this must be subclassed in your application.
#
# Important: Authorization is left up to individual Controller classes/methods, this 
# just determines if the user is valid.

use MooseX::Declare;

class Arizona::Engine::Authenticator {
   
    use Method::Signatures::Simple name => 'action';

    use Arizona::Err::LoginFailed;
 
    # return a subclass of Arizona::Model::User (or something duck-type-compatible) *OR*
    # raise an error.   Applications must subclass this. 
    def authenticate() {
        die Arizona::Err::LoginFailed->new(text => 'authenticator not implemented, please subclass');
    }

}
