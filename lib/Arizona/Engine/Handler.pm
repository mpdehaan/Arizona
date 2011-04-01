# code to be used in creating a top end Dancer application.
# your application should always subclass this.

use MooseX::Declare;

use strict;
use warnings;
use MIME::Types;
use Try::Tiny;
use Arizona::Err::Forbidden;
use Arizona::Engine::ErrorCatcher;
use Arizona::Engine::Loader;

class Arizona::Engine::Handler {

   use Method::Signatures::Simple name => 'action';

   has is_rest   => (is => 'rw', isa => 'Bool',   default => 0);
   has noun      => (is => 'rw', isa => 'Str',    required => 1);
   has verb      => (is => 'rw', isa => 'Str',    required => 1);
   has category  => (is => 'rw', isa => 'Str',    required => 1);
   has request   => (is => 'rw', isa => 'Object', required => 1);

   has namespace => (is => 'rw', isa => 'Str',    lazy => 1, builder => '_make_namespace');
   has target    => (is => 'rw', isa => 'Str',    lazy => 1, builder => '_make_target');      
 
   action _make_namespace() {
       my $namespace = $self->namespaces()->{$self->category()};
   }

   # defines what controllers are loadable
   action namespaces() {
       die "must override in subclass";
   }

   # optional startup code.
   # if you're using Elevator, might want to do something like clear & enable the object cache here.
   action setup_hook() {
   }

   # used to serve routes
   action dynamic_call() {
       $self->is_rest() if ($self->category() eq 'Rest');
       $self->setup_hook();
       try {
           return $self->_make_request();
       } catch {
           return Arizona::Engine::ErrorCatcher->new()->handle($_, $self->is_rest());
       };
   }

   # optional pre-request hook
   action _pre_request() {
   }

   action _make_target() {
      # this is so we don't have to use colons in the URL, which looks weird to humans
      my $_noun = $self->noun();
      $_noun =~ s/_/::/g;
      $_noun =~ s/-/::/g;
      return $self->namespace() . "::" . $_noun . "::" . $self->verb();
   }

   # dynamically load a controller and execute it
   action _make_request() {
       $self->_pre_request();
       die Arizona::Err::Forbidden->new(text => 'invalid namespace') unless $self->namespace();
       my $user    = $self->get_user();
       my $target  = $self->target();
       $self->request($self->enable_cookies());
       return Arizona::Engine::Loader->new(
           is_rest          => $self->is_rest(),
           class_and_method => $self->target(),
           request          => $self->request(),
           user             => $user
       )->invoke();
   }

   # tweak the Dancer request object so it can manipulate cookies.
   # we'll pass this request through the app, but other modules won't use/import Dancer.
   action enable_cookies() {
      my $_request = $self->request();
      $_request->{set_cookie} = \&set_cookie;
      $_request->{cookies} = \&cookies;
      return $_request;
   }

   # must either return a user object or raise an exception (like Arizona::Err::LoginFailed)
   action get_user($namespace, $request) {
       die "get user must be implemented in a subclass";
   }

}
