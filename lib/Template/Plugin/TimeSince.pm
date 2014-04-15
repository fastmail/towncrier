package Template::Plugin::TimeSince;

use warnings;
use strict;
use base 'Template::Plugin';

use DateTime::Format::Human::Duration;
my $formatter = DateTime::Format::Human::Duration->new;

sub new {
    my ($class, $context, $params) = @_;
    return bless {}, $class;
}

sub timesince {
    my ($self, $dt) = @_;
    my $now = DateTime->now;

    $formatter->format_duration_between(DateTime->now, $dt,
        significant_units => 1,
        past => "%s ago",
        no_time => "just now",
    );
}

1;
