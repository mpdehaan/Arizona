# Arizona::Engine::Loader
#
# Wrapper around the dynamic loading and invocation of controller
# methods, called by Engine::Handler

##########################################################################

use MooseX::Declare;

class Arizona::Engine::Loader {
    
    use Method::Signatures::Simple name => 'action';

    # what class and method to call
    has class_and_method => (isa => 'Str', is => 'rw', required => 1);

    # derived from the class_and_method:
    has module  => (isa => 'Str', is => 'rw', required => 0);
    has method  => (isa => 'Str', is => 'rw', required => 0);

    # user that we've already authenticated in Handler
    has user    => (isa => 'Object', is => 'rw', required => 1);

    # the Dancer request object
    has request => (isa => 'Object', is => 'rw', required => 1);

    # is this a JSON function instead of a page?
    has is_rest => (isa => 'Bool', is => 'rw', required => 1);

    # constructor.  Generates the module and method, but not much else.
    action BUILD() {
        my ($class, $method) = $self->__get_parts($self->class_and_method());
        $self->module($class);
        $self->method($method);
    }

    # wrapper around JSON encoding to allow for overriding on subclass, in case
    # you want additional JSON::XS options (like canonical, allow_nonref, etc)
    action json_encode($datastruct) {
        return JSON::XS::encode_json($datastruct);
    }

    # wrapper around JSON decoding.
    action json_decode($str) {
        return JSON::XS::decode_json($str); 
    }

    # Loads a module by name, and invokes a method from within that module.
    # This is called from Handler.

    action invoke() {

         my $input_data = undef;

         # REST calls need re-jsonification of input so we can pass a datastructure
         # to the controller so each controller does not have to do JSON handling
         if ($self->is_rest()) {
             # look for JSON in either the request body or the query string
             # choke if JSON is invalid
             eval {
                  if ($self->request->body()) {
                      $input_data = $self->json_decode($self->request->body());
                  }
                  else {
                      $input_data = $self->request->params();
                  }
             } or die Arizona::Err::Forbidden->new(text => "invalid JSON");
         }

         # in the controller, JSON/REST API methods start with "API_" and view
         # only pages for humans start with "RENDER_".   Preferably, no pages affect state change
         # and the whole app is ajaxified.
         my $method_name = sprintf "%s_" . $self->method(), $self->is_rest() ? 'API' : 'RENDER';

         # modules have to start with Arizona::, which prevents requesting to run
         # methods in other classes.  This is in addition to the method name
         # restrictions above.  
         die Arizona::Err::Forbidden->new(text => "disallowed module") unless $self->module() =~ /^([A-Za-z0-9:_])+$/;
         die Arizona::Err::Forbidden->new(text => "invalid module") unless $self->module() =~ /::Controller::/;

         my $result = '';

         # to use a module it must be included in Controller::Controllers.pm
         # for REST calls, gather the return object's datastructures and auto-convert into JSON
         # controller does not have to do JSON handling itself.
         if ($self->is_rest()) {
             $result = $self->module()->$method_name($self->user(), $input_data, $self->request());
             die Arizona::Err::InternalError->new(text => 'improper return') unless $result->isa('Arizona::Engine::Return');
             return $result->to_json_str();
         } 

         # non-REST calls are simpler, and just return strings
         return $self->module()->$method_name($self->user(), scalar $self->request->params(), $self->request());
    }

   # used to split data out of the URL, this should really be moved into Handler?
   action __get_parts($class_and_method) {
       my @tokens = split /::/, $class_and_method;
       my $method = $tokens[-1];
       pop(@tokens);
       my $class = join '::', @tokens;
       return ($class, $method);
   }


}
