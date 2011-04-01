# Arizona::Engine::Loader
#
# Dynamically load controllers

##########################################################################

use MooseX::Declare;

class Arizona::Engine::Loader {
    
    use Method::Signatures::Simple name => 'action';

    has class_and_method => (isa => 'Str', is => 'rw', required => 1);
    has module  => (isa => 'Str', is => 'rw', required => 0);
    has method  => (isa => 'Str', is => 'rw', required => 0);
    has user    => (isa => 'Object', is => 'rw', required => 1);
    has request => (isa => 'Object', is => 'rw', required => 1);
    has is_rest => (isa => 'Bool', is => 'rw', required => 1);

    
    action BUILD() {
        my ($class, $method) = $self->__get_parts($self->class_and_method());
        $self->module($class);
        $self->method($method);
    }

    action json_encode($datastruct) {
        return JSON::XS::encode_json($datastruct);
    }

    action json_decode($str) {
        return JSON::XS::decode_json($str); 
    }

    # Loads a module by name, and invokes a method from within that module.
    # invoke or invoke_json both call this method.

    action invoke() {

         my $input_data = undef;
         if ($self->is_rest()) {
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

         # instantiate the controller class
         my $obj;
         eval {
             $obj = $self->module()->new();
         } or do {
             # either a syntax error or an invalid path, though we won't tell userland.
             # developers check for syntax errors by doing 'perl Arizona/Controller/Foo/Bar.pm'
             # and make sure your URLs are correct.
             die Arizona::Err::InternalError->new(text => "cannot load requested module");
         }; 

         my $result = '';
         if ($self->is_rest()) {
             $result = $obj->$method_name($self->user(), $input_data, $self->request());
             die Arizona::Err::InternalError->new(text => 'improper return') unless $result->isa('Arizona::Engine::Return');
             return $result->to_json_str();
         } 
         return $obj->$method_name($self->user(), scalar $self->request->params(), $self->request());
    }

   # used to split data out of the URL.

   action __get_parts($class_and_method) {
       my @tokens = split /::/, $class_and_method;
       my $method = $tokens[-1];
       pop(@tokens);
       my $class = join '::', @tokens;
       return ($class, $method);
   }


}
