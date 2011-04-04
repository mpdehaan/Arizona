Getting Started
===============

Arizona is a set of baseclasses for a web application, and also a sample starter web application (see examples).

It's expected you'll want to copy everything in examples and start making it your own, deleting Controllers and
adding new ones, adding templates, etc.

To test your app, run phoenix.pl in the examples directory (or your version of it).   The Makefile provides
a nice shortcut to this.

You may wish to install Arizona::Bundle::Arizona to install the prerequisite 3rd party libraries.

Deploying
=========

Obviously testing with running phoenix.pl directly is not such a great idea for production sites, though it may be fine
for in-house internal GUIs.

Dancer has docs on deployment, and you should read those.   

Plack inside Apache works well:

<Location /web>
    SetHandler perl-script
    PerlHandler Plack::Handler::Apache2
    PerlSetVar psgi_app /path/to/phoenix.pl
</Location>

You'll need to make sure PerlSetVar PERL5LIB is also set appropriately.

Note that because Arizona uses Moose it's a VERY good idea to also do a PerlModule Acme::SomeInclude in your Apache configuration
as well to pre-"immutabilize" the Perl code.  Otherwise every time Apache retires and recreates a child there will be some
delay, which can be many seconds for larger applications.  It's much better to pay this cost when starting Apache, before it forks.


