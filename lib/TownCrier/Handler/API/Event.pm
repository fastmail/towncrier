package TownCrier::Handler::API::Event;

use TownCrier::Data;
use Dancer qw(params status var);
use Defined::KV;

sub list {
    my $db = var 'db';
    my $service = $db->match(class => "TownCrier::Data::Service", id => params->{service})->[0];
    return status 'not_found' unless $service;
    { events => [ map { $_->rest }
                    @{$db->match(class => "TownCrier::Data::Event", service => $service->id,
                                 { sort => sub { my ($a, $b) = @_; $b->ordered_compare($a) } })} ] }
}

sub list_all {
    my $db = var 'db';
    { events => [ map { $_->rest }
                    @{$db->match(class => "TownCrier::Data::Event",
                                 { sort => sub { my ($a, $b) = @_; $b->ordered_compare($a) } })} ] }
}

sub _add_service_event {
    my ($service, $status, $message, $timestamp) = @_;

    my $event = TownCrier::Data::Event->new(
        service => $service,
        status => $status,
        defined_kv(message => $message),
        $timestamp ? (timestamp => DateTime::Format::ISO8601->parse_datetime(params->{timestamp})) : (),
    );

    if (!$service->event || $service->event->timestamp lt $event->timestamp) {
        $service->event($event);
        $service->status($status);
    }

    return $event;
}

sub post {
    my $db = var 'db';

    my $params = params();
    my $status_id = $params->{status};
    my $message = $params->{message};
    my $timestamp = $params->{timestamp};
    return status 'bad_request' unless $status_id;

    my $service = $db->match(class => "TownCrier::Data::Service", id => params->{service})->[0];
    return status 'not_found' unless $service;

    my $status = $db->match(class => "TownCrier::Data::Status", id => $status_id)->[0];
    return status 'not_found' unless $status;

    my $event = _add_service_event($service, $status, $message, $timestamp);

    $db->txn_do(sub {
        $db->store($event);
        $db->store($service);
    });

    status 'created';
    return $event->rest;
}

sub post_all {
    my $db = var 'db';

    my $params = params();
    my $status_id = $params->{status};
    my $message = $params->{message};
    my $timestamp = $params->{timestamp};
    return status 'bad_request' unless $status_id;

    my $status = $db->match(class => "TownCrier::Data::Status", id => $status_id)->[0];
    return status 'not_found' unless $status;

    my @services = @{$db->match(class => "TownCrier::Data::Service")};

    my @events = map { _add_service_event($_, $status, $message, $timestamp) } @services;

    $db->txn_do(sub {
        $db->store($_) for @events;
        $db->store($_) for @services;
    });

    status 'created';
    return { events => [ map { $_->rest } @events ] };
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

    my $event = $db->match(class => "TownCrier::Data::Event", id => params->{event})->[0];
    return status 'not_found' unless $event;

    return status 'not_found' unless $service->id eq $event->service->id;

    $db->txn_do(sub {
        if ($service->event && $service->event->id eq $event->id) {
            $service->clear_event;
            $service->clear_status;
            $db->store($service);
        }
        $db->delete($event);
    });
    return status 'ok';
}

1;
