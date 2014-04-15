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
        entries => [ map { +{
            title => $_->service->name . " - " . $_->status->name,
            modified => DateTime::Format::ISO8601->parse_datetime($_->timestamp),
            content => $_->message,
        } } @events ],
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
        entries => [ map { +{
            title => $_->service->name . " - " . $_->status->name,
            modified => DateTime::Format::ISO8601->parse_datetime($_->timestamp),
            content => $_->message,
        } } @events ],
    );
}

1;
