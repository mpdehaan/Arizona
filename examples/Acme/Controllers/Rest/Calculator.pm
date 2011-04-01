# controller for:
# /Rest/SomeMethods/add
# /Rest/SomeMethods/multiply_by_zero

##########################################################################

use MooseX::Declare;

class Acme::Controller::Rest::Calculator {

    use Arizona::Engine::Return;   
    use Method::Signatures::Simple name => 'action';
 
    action API_add($authenticated_user, $input, $request) {
        # input is a hash of already decoded JSON
        warn "*** ADDITION INPUTS: *** \n";
        warn Data::Dumper::Dumper $input;
        warn "body=" . $request->body() ."\n";
        my $a   = $input->{a};
        my $b   = $input->{b};
        my $sum = $a+$b;
        # return object will auto-jsonify 
        return Arizona::Engine::Return->new( data => { sum => $sum } );
    }

    # add other API methods here, just make API_*, etc.


}
