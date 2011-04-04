Arizona
=======

Arizona is a mini-MVC, all-AJAX-all-the-time web framework built on top of a micro-framework.

The micro-framework is Perl's most-excellent Dancer, which is inspired by Ruby's Sinatra.
Arizona also puts some abstractions around minimal use of HTML::Mason for templating.
 
Arizona is designed to be 100% AJAX with pluggable controllers so you don't end 
up with a mammoth routes file. Just add code.

Arizona also offers improvements to error handling, featuring polymorphic typed exceptions that can JSON-ify themselves and 
dictate their own error codes and templates.

Don't you hate it when your web framework comes with a model you don't like?  Arizona doesn't.

You can bring your own model.  Might we suggest github.com/webassign/Elevator?

License
=======

Arizona is MIT licensed open source software.  See COPYING for more details.

Documentation / Getting Started
===============================

Browse the 'examples' folder to see how an application is built with Arizona.

Also see the 'docs' folder for more documentation, including setup, deployment info, and pointers
to documentation on related libraries to read.

There's also a todo about future feature plans in the 'docs' folder.

Questions/Comments?  Want to send in a patch?
=============================================

For now, send bugs at patch requests to github.com/webassign, you will need a github account.
Until a discussion list is available, feel free to email mpdehaan@webassign.net.

Contributors
============

Arizona was originally created by Michael DeHaan for http://webassign.net/, and contains some differences in this release to make it more generic than the original.

### In (Approximate) Order of Appearance: ###

* Michael DeHaan <michael.dehaan@gmail.com/mpdehaan@webassign.net>
* Mike Morella
* Ian Quattlebaum
* Shawn Page
* Robert Johnson
* Ben Wheeler

Send in a patch to get your name here.

