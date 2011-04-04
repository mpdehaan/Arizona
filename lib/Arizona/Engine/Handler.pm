# main entry point code to be used in creating a top end Dancer application.
# your application should always subclass this to define it's own template
# engine wrapper, default error class, and handler.

use MooseX::Declare;

use strict;
use warnings;
use MIME::Types;
use Arizona::Err::Forbidden;
use Arizona::Engine::Loader;
use Arizona::Engine::ErrorCatcher;

class Arizona::Engine::Handler {

   use Method::Signatures::Simple name => 'action';

   # are we serving a JSON/REST request?
   has is_rest   => (is => 'rw', isa => 'Bool',   default => 0);

   # what Controller to target?
   has noun      => (is => 'rw', isa => 'Str',    required => 1);

   # what Method in the Controller to target?
   has verb      => (is => 'rw', isa => 'Str',    required => 1);

   # this is something like 'Page' or 'Rest' and is a top level directory
   # containing different types of controllers.
   has category  => (is => 'rw', isa => 'Str',    required => 1);

   # the Dancer request object.
   has request   => (is => 'rw', isa => 'Object', required => 1);

   # an organization-specific subclass of Arizona::Engine::Templar
   has templar   => (is => 'rw', isa => 'Object', required => 1);

   # an organization-specific subclass of an Arizona::Err::<someclass>
   has default_error => (is => 'rw', isa => 'Object', required => 1);

   # derived from the inputs, these represent the Perl location corresponding to the category/noun/verb
   has namespace => (is => 'rw', isa => 'Str',    lazy => 1, builder => '_make_namespace');
   has target    => (is => 'rw', isa => 'Str',    lazy => 1, builder => '_make_target');      
    
   # find the Perl module path
   action _make_namespace() {
       my $namespace = $self->namespaces()->{$self->category()};
   }

   # defines what controller namespaces are loadable, this should return a hash (see examples)
   # and is a security gate preventing loading of arbitrary modules
   action namespaces() {
       die "must override in subclass";
   }

   # optional startup code called before making each new request
   # if you're using Elevator, might want to do something like clear & enable the object cache here.
   action setup_hook() {
   }

   # used to serve routes (see examples/phoenix.pl).  Call after constructing the object.
   action dynamic_call() {
       $self->is_rest() if ($self->category() eq 'Rest');
       $self->setup_hook();
       eval {
           return $self->_make_request();
       } or do {
           my $error = $@;
           return Arizona::Engine::ErrorCatcher->new(
               default_error => $self->default_error(),
               templar => $self->templar())->handle($error, $self->is_rest()
           );
       };
   }

   # optional pre-request hook
   action _pre_request() {
   }

   # come up with Perl function name to call, including module 
   # i.e. Acme::Controllers::Page::Foo::RENDER_method
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
       # loader wraps the actual dynamic call to the module.  Handler mostly is there to figure
       # out how to invoke the loader.  It should be possible to merge these two modules and simplify.
       return Arizona::Engine::Loader->new(
           is_rest          => $self->is_rest(),
           class_and_method => $self->target(),
           request          => $self->request(),
           user             => $user
       )->invoke();
   }

   # tweak the Dancer request object so it can manipulate cookies.
   # we'll pass this request through the app, but other modules won't use/import Dancer directly.
   action enable_cookies() {
      my $_request = $self->request();
      $_request->{set_cookie} = \&set_cookie;
      $_request->{cookies} = \&cookies;
      return $_request;
   }

   # must either return a user object or raise an exception (like Arizona::Err::LoginFailed)
   # this is the authentication code for the app, see examples.
   action get_user($namespace, $request) {
       die "get user must be implemented in a subclass";
   }

}
