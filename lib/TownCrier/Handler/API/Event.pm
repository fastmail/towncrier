package TownCrier::Handler::API::Event;

use TownCrier::Data;
use Dancer qw(params status var);

sub list {
    my $db = var 'db';
    my $service = $db->match(class => "TownCrier::Data::Service", id => params->{service})->[0];
    return status 'not_found' unless $service;
    { events => [ map { $_->rest }
                    @{$db->match(class => "TownCrier::Data::Event", service => $service->id,
                                 { sort => sub { my ($a, $b) = @_; $b->ordered_compare($a) } })} ] }
}

sub post {
    my $db = var 'db';

    my @params = @{params()}{qw(status message)};
    return status 'bad_request' unless @params == 2;
    my ($status_id, $message) = @params;

    my $service = $db->match(class => "TownCrier::Data::Service", id => params->{service})->[0];
    return status 'not_found' unless $service;

    my $status = $db->match(class => "TownCrier::Data::Status", id => $status_id)->[0];
    return status 'not_found' unless $status;

    my $event = TownCrier::Data::Event->new(
        service => $service,
        status => $status,
        message => $message,
        params->{timestamp} ? (timestamp => DateTime::Format::ISO8601->parse_datetime(params->{timestamp})) : (),
    );

    if (!$service->event || $service->event->timestamp lt $event->timestamp) {
        $service->event($event);
        $service->status($status);
    }

    $db->txn_do(sub {
        $db->store($event);
        $db->store($service);
    });

    status 'created';
    return $event->rest;
}

sub get {
    my $db = var 'db';

    my $service = $db->match(class => "TownCrier::Data::Service", id => params->{service})->[0];
    return status 'not_found' unless $service;

    my $event = $db->match(class => "TownCrier::Data::Event", id => params->{event})->[0];
    return status 'not_found' unless $event;

    return status 'not_found' unless $service->id eq $event->service->id;

    return $event->rest;
}

sub delete {
    my $db = var 'db';

    my $service = $db->match(class => "TownCrier::Data::Service", id => params->{service})->[0];
    return status 'not_found' unless $service;

    my $event = TownCrier::Data::Event->get_by_id($db, params->{event});
    return status 'not_found' unless $event;

    return status 'not_found' unless $service->id eq $event->service->id;

    $db->txn_do(sub {
        if ($service->event && $service->event->id eq $event->id) {
            $service->event(undef);
            $service->status(undef);
            $db->store($service);
        }
        $db->delete($event);
    });
    return status 'ok';
}

1;
