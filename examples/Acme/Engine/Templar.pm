# Acme::Engine::Templar;
# 
# organization specific subclass of Templar
# defining our own Mason roots and adding in some site-specific parameters

use MooseX::Declare;

class Acme::Engine::Templar extends Arizona::Engine::Templar {

    use Method::Signatures::Simple name => 'action';
    use IO::All;
    use JSON::XS;
    use DateTime;

    has configuration => (isa => 'HashRef', is => 'rw', lazy => 1, builder => '_make_configuration');

    action _make_configuration() {
        my $data = io('examples/mason.conf')->slurp();
        return JSON::XS::decode_json($data);
    }

    # return the filesystem path to where the Mason cache will live
    action mason_data() {
        return $self->configuration->{mason_data} or die "missing mason_data configuration";
    }
     
    # return the filesystem path where the Mason templates/components live   
    action mason_root() {
        return $self->configuration->{mason_root} or die "missing mason_root configuration";
    }        

    # if you'd like to supply any additional variables to EVERY template, tweak this in a subclass.
    action add_additional_parameters($mason_params) {
        $mason_params->{time} = DateTime->now();
    }

    # optional hook for post processing things after they come out of Mason
    action post_process($template_output) {
        # silly example, most users won't need this
        $template_output =~ s/YCDPPH/you can do post processing here/g;
        return $template_output;
    }

} 
