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
        # input is a hash from the query string and/or POST data
        # render the view
        return Acme::Engine::Templar->new(
            template   => "/templates/calculator/display.tpl",
            user       => $authenticated_user,
            title      => 'Calculator',
            request    => $request,
            parameters => {
                 hostname => Sys::Hostname::hostname(),
            },
        )->render_page();
    }

    action RENDER_help($authenticated_user, $input, $request) {
        return "no help for you";
    }

    action RENDER_error($authenticated_user, $input, $request) {
        die "example error";
    }

}
