# a simple example controller that renders various web pages.
# as this is a page controller, all they do is call templates
# show things to the user.   Actual saving happens via REST
# methods ina  different controller.  Classical/retro form submissions
# do not exist.
#
# controller for:
# /Page/Calculator/display 
# /Page/Calculator/help

##########################################################################

use MooseX::Declare;

class Acme::Controller::Page::Calculator {
   
    use Method::Signatures::Simple name => 'action';
    use DateTime;
    use Acme::Engine::Templar;
    use Sys::Hostname;
   
    action RENDER_display($authenticated_user, $input, $request) {
        # input is a hash from the query string + POST data
        # now render the view using our organization subclass of templar
        return Acme::Engine::Templar->new(
            template   => "/templates/calculator/display.tpl",
            user       => $authenticated_user,
            title      => 'Calculator',
            request    => $request,
            # we can pass any arbitrary parameters we want
            # Templar.pm also adds some for free that do not have to 
            # be repeated here
            parameters => {
                 hostname => Sys::Hostname::hostname(),
            },
        )->render_page();
    }

    # technically you don't have to use templar, any string return
    # will serve up a page
    action RENDER_help($authenticated_user, $input, $request) {
        return "no help for you";
    }

    # here's a demo of a page that returns an error, that can be used
    # to show that the error handler works
    action RENDER_error($authenticated_user, $input, $request) {
        die "example error";
    }

}
