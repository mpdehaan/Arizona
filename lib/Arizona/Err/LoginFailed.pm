# Error raised by platform when logins fail due to bad credentials.

use MooseX::Declare;

class Arizona::Err::LoginFailed extends Arizona::Err::AuthError {

    use Method::Signatures::Simple name => 'action';

    # on error, redirect page to...
    # FIXME: use WebAssign config to redirect to developer environments also?
    action redirect() {
        return "https://www.webassign.net/login.html?message=user"
    }

    # forbidden errors are not currently logged
    action should_log() {
       return 0;
    }


}


