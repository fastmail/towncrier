package TownCrier::Handler::Feed;

use TownCrier::Data;
use Dancer ':syntax';
use Dancer::Plugin::Feed;
use DateTime::Format::ISO8601;

sub index {
    my $db = var 'db';

    my @events = splice @{$db->match(
        class => "TownCrier::Data::Event",
        { sort => sub { my ($a, $b) = @_; $b->ordered_compare($a) } }
    ) }, 0, 10;

    create_feed(
        format => "RSS",
        title => "FastMail Status",
        link => request->uri_base . request->path,
        entries => [ map {
            my $dt = DateTime::Format::ISO8601->parse_datetime($_->timestamp . "Z");
            {
                title => $_->service->name . " - " . $_->status->name,
                issued => $dt,
                modified => $dt,
                content => $_->message,
                id => $_->id,
            }
        } @events ],
    );
}

sub service {
    my $db = var 'db';
    my $service = $db->match(class => "TownCrier::Data::Service", id => params->{service})->[0];
    return status 'not_found' unless $service;

    my @events = splice @{$db->match(
        class => "TownCrier::Data::Event", service => $service->id,
        { sort => sub { my ($a, $b) = @_; $b->ordered_compare($a) } }
    ) }, 0, 10;

    create_feed(
        format => "RSS",
        title => "FastMail Status - ".$service->name,
        link => request->uri_base . request->path,
        entries => [ map {
            my $dt = DateTime::Format::ISO8601->parse_datetime($_->timestamp . "Z");
            {
                title => $_->service->name . " - " . $_->status->name,
                issued => $dt,
                modified => $dt,
                content => $_->message,
                id => $_->id,
            }
        } @events ],
    );
}

1;
