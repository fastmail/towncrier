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

    my $diff = $now->epoch - $dt->epoch;

    return
        $diff < 60   ? "less than a minute ago"  :
        $diff < 150  ? "a couple of minutes ago" :
        $diff < 300  ? "a few minutes ago"       :
        $diff < 390  ? "about 5 minutes ago"     :
        $diff < 750  ? "about 10 minutes ago"    :
        $diff < 1050 ? "about 15 minutes ago"    :
        $diff < 1320 ? "about 20 minutes ago"    :
        $diff < 1650 ? "about 25 minutes ago"    :
        $diff < 2220 ? "about half an hour ago"  :
        $diff < 3120 ? "about 45 minutes ago"    :
        $diff < 3600 ? "about an hour ago"       :
        $formatter->format_duration_between($now, $dt,
            significant_units => 1,
            past => "%s ago",
            no_time => "just now",
        );
}

1;
