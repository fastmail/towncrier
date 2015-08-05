package TownCrier::Handler::Admin::Event;

use TownCrier::Data;
use Dancer ':syntax';

use constant TOWNCRIER_TITLE =>
    $ENV{TOWNCRIER_TITLE} // config->{towncrier}->{title} // "";
use constant TOWNCRIER_DEFAULT_STATUS =>
    $ENV{TOWNCRIER_DEFAULT_STATUS} // config->{towncrier}->{default_status} // "up";

sub _template_params {
    return (
        title  => TOWNCRIER_TITLE,
    );
}

sub form {
    my $db = var 'db';

    my $statuses = $db->match(class => "TownCrier::Data::Status");

    my $services = $db->match(class => "TownCrier::Data::Service",
                              { sort => sub { my ($a, $b) = @_; $a->ordered_compare($b) } });

    my $default_status = $db->match(
        class => "TownCrier::Data::Status",
        id => TOWNCRIER_DEFAULT_STATUS,
    )->[0];

    template "admin/event" => {
        _template_params,
        services => $services,
        statuses => $statuses,
        default_status => $default_status,
        @_,
    }
}

sub submit {
    my $db = var 'db';

    my @params = @{params()}{qw(service status message)};
    return form unless @params == 3;
    my ($service_id, $status_id, $message) = @params;

    return form warning => "No message provided" unless length $message;

    my $service = $db->match(class => "TownCrier::Data::Service", id => $service_id)->[0];
    return form warning => "Service '$service_id' not found" unless $service;

    my $status = $db->match(class => "TownCrier::Data::Status", id => $status_id)->[0];
    return form warning => "Status '$status_id' not found" unless $status;

    my $event = TownCrier::Data::Event->new(
        service => $service,
        status => $status,
        message => $message,
    );

    if (!$service->event || $service->event->timestamp lt $event->timestamp) {
        $service->event($event);
        $service->status($status);
    }

    $db->txn_do(sub {
        $db->store($event);
        $db->store($service);
    });

    return redirect '/';
}

1;
