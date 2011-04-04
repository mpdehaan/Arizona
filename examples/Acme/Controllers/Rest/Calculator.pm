# controller for:
#    /Rest/Calculator/add

##########################################################################

use MooseX::Declare;

class Acme::Controller::Rest::Calculator {

    use Arizona::Engine::Return;   
    use Method::Signatures::Simple name => 'action';

    # this controller just includes one example function, but could return more.
    #
    # example input:  {
    #     a => 4
    #     b => 5
    # }
    #
    # example output: {
    #     data => {
    #         sum => 9
    #     }
    # }
    #
    # on error, errors are automatically converted to JSON (see Arizona::Err) and have an
    # HTTP status code, and have a JSON body:
    #     { code => 500, text => 'some text about the error' }
    # on success, the status code is HTTP 200 OK
 
    action API_add($authenticated_user, $input, $request) {
        # input is a hash of already decoded JSON
        # NOTE: normally you'd call into Model code here.  
        #       business logic in controllers is not good form, but this is just a demo
        #       and Arizona lets you bring your own model system.
        my $a   = $input->{a};
        my $b   = $input->{b};
        my $sum = $a+$b;
        # return object will auto-jsonify, returns of other object types is not allowed
        return Arizona::Engine::Return->new( data => { sum => $sum } );
    }

    # add other API methods here, just make API_*, etc.

}
