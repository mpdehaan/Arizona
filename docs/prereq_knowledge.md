Prerequisite Knowledge
======================

Arizona is built heavily on Dancer to drive web requests and HTML::Mason to render
the view.

As it provides the object system besides Arizona, you should learn Moose and MooseX::Declare.

You should read http://perldancer.org and know most of it, but you can ignore the parts about
templating, logging, configuration, and REST.  Arizona provides it's own more idiomatic
ways of doing these things.

It's not recommended that you learn a lot of Mason though.  Mason can almost
act as a controller, and support it's own concept of functions and methods.
Arizona likes to use Mason as if it were Ruby's ERB -- look up parts of Mason
you need, but for the most part, limit yourself to iteration and displaying
things from the model.  Business logic should live in the model.  Arizona likes
thin controllers and read-only views.  Mason can tend to encourage views that
"think" which is not what a good MVC architecture should do.

You're also going to need a Model, as Arizona only supplies the Controller and View system.
Elevator (github.com/webassign/Elevator) is highly recommended and has a very compatible
style, it also uses MooseX::Declare.   

