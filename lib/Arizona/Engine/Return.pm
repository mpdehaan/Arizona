# class for REST returns
# ensures only certain information can be passed to web pages and that
# everything is consistent.  Do not subclass this.

use MooseX::Declare;

class Arizona::Engine::Return {

   use Method::Signatures::Simple name => 'action';
   use JSON::XS;

   # a serialized object or datastructure
   # if using Elevator, $obj->to_datastruct is great
   has data     => (is => 'rw', isa  => 'HashRef');
   
   # $obj->extended_data, where available.  This is a place to store additional data
   # about the object that might be derived and not explicitly in a database, or any other
   # semantics you might like.  It would be best to avoid using this if you don't have a reason for it.
   has extended => (is => 'rw', isa  => 'HashRef');
   
   # a message to use in 'flash' type view display.   Should never control behavior, but could be used
   # to send a human-readable explanation or string key.  
   has message  => (is => 'rw', isa => 'Str');

   # XML to use to dynamically update portions of a page (used as return of REST calls)
   # Arizona doesn't actually supply anything for this, client code is up to you.
   has live_update => (is => 'rw', isa => 'Str');

   # normally we'd use Elevator (github.com/mpdehaan/Elevator)
   # but here we are decoupling things, feel free to use something duck-type compatible in your deployment.

   action to_datastruct() {
       return {
           data        => $self->data(),
           extended    => $self->extended(),
           message     => $self->message(),
           live_update => $self->live_update()
       };
   }

   # return the JSON version of this error mesage.

   action to_json_str() {
       return JSON::XS::encode_json($self->to_datastruct());
   }
  
}
