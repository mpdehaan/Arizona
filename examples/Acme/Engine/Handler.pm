# organization specific subclass of Arizona's stock Handler.

use MooseX::Declare;

class Acme::Engine::Handler extends Arizona::Engine::Handler {

   use Method::Signatures::Simple name => 'action';
   use Acme::Model::User;

   # defines what URL segments map to what Perl code.
   # 'Rest' is magic and implies jsonification.
   action namespaces() {
       return {
           'Rest' => 'Acme::Controller::Rest',
           'Page' => 'Acme::Controller::Page',
       };
   }

   # if you're using Elevator, might want to do something like enable the object cache here.
   action setup_hook() {
   }

   # must either return a user object or raise an exception (like Arizona::Err::LoginFailed)
   action get_user($namespace, $request) {
       # if we wanted to fail, we could do things like:
       # get the data you need to authenticate from the request object
       # how to fail a login:
       #      die Arizona::Err::LoginFailed->new(text => 'invalid password');
       return Acme::Model::User->new(name => 'example user only');
   }


}
