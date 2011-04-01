# Arizona::Engine::Templar;
# 
# This is a wrapper around Mason to be invoked by
# a controller to render the view.    Templater was too hard to say.
# 
# Currently it handles Mason, but it may also deal with other template
# systems.

use MooseX::Declare;

class Arizona::Engine::Templar {

    use Method::Signatures::Simple name => 'action';

    use HTML::Mason; # against our will
    use Data::Dumper;
    use Digest::MD5;

    # path to the template.  Currently supports only Mason, but probably won't always.
    has template   => (isa => 'Str',          is => 'ro', required => 1);
    
    # title for HTML templates
    has title      => (isa => 'Str',          is => 'ro', required => 0, default => '');

    # a hash of variables to make available to the template
    has parameters => (isa => 'HashRef',      is => 'rw', required => 1);

    # the Arizona::Model::User (or duck-type compatible class) that is logged in
    has user       => (isa => 'Object',       is => 'ro', required => 1);
  
    # Dancer request object (your templates should NOT really need this, Views should be dumb).
    has request    => (isa => 'Object|Undef',  is => 'ro', required => 0);

    # return the filesystem path to where the Mason components live.
    action mason_root() {
        die "not implemented";
    }

    # return the filesystem path to where the Mason cache will live
    action mason_data() {
        die "not implemented";
    }
        
    # if you'd like to supply any additional variables to EVERY template, tweak this in a subclass.
    action add_additional_parameters($mason_params) {
        return;
    }

    # optional hook for post processing things after they come out of Mason
    action post_process($template_output) {
        return $template_output;
    }

    action _render() {
        my $outbuf = "";
        
        my $interp = HTML::Mason::Interp->new(
            comp_root     => $self->mason_root(),
            data_dir      => $self->mason_data(),
            out_method    => \$outbuf,
        );
        
        my $mason_params = $self->parameters();

        # These are globalish.  We want to minimize these as much as possible and only add something there
        # if absolutely every page needs them.   NOTE: this may eventually grow student/faculty specific.
        # if so, it may need to work like Finder and have a different render method sharing common code between
        # the two.  Right now it asks the (authenticated) user if they are faculty to fill in their sections
        # but if they are visiting a student side page this data is simply not referenced by the templates
        # ... but this practice should probably not be continued.

        $mason_params->{template_name}      = $self->template();
        $mason_params->{title}              = $self->title(),
        $mason_params->{authenticated_user} = $self->user();

        $self->add_additional_parameters($mason_params);

        # run through Mason and then post-process the statics. 
        # paths starting with /static or /wastatic become /static/wacache<md5:version> and 
        # /wastatic/wacache/<md5:version>
        $interp->exec($self->template(), %{$mason_params});

        return $self->post_process($outbuf);
    }

    # called to return a regular HTML page
    action render_page() {
        return $self->_render();
    }

} 
