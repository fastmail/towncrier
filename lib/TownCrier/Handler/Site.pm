package TownCrier::Handler::Site;

use TownCrier::Data;
use Dancer ':syntax';
use DateTime;
use DateTime::Format::DateParse;

use constant TOWNCRIER_TITLE =>
    $ENV{TOWNCRIER_TITLE} // config->{towncrier}->{title} // "";
use constant TOWNCRIER_DEFAULT_STATUS =>
    $ENV{TOWNCRIER_DEFAULT_STATUS} // config->{towncrier}->{default_status} // "up";

sub _template_params {
    return (
        title  => TOWNCRIER_TITLE,
    );
}

sub index {
    my $db = var 'db';

    my $statuses = $db->match(class => "TownCrier::Data::Status");

    my $group_id;
    if (params->{group}) {
        my $group = $db->match(class => "TownCrier::Data::Group", id => params->{group})->[0];
        return status 'not_found' unless $group;
        $group_id = $group->id;
    }

    my $services = $db->match(class => "TownCrier::Data::Service", $group_id ? (group => $group_id) : (),
                              { sort => sub { my ($a, $b) = @_; $a->ordered_compare($b) } });

    my $default_status = $db->match(
        class => "TownCrier::Data::Status",
        id => TOWNCRIER_DEFAULT_STATUS,
    )->[0];

    my $now = DateTime->now;
    my $today = $now->clone->truncate(to => "day" );

    my @days = do {
        my $day = $today->clone;
        ( { date => $today, today => 1 },
            map { { date => $day->add({ days => -1 })->clone } } (1..5) );
    };

    my $groups = { map { $_->id => $_ } @{$db->match(class => "TownCrier::Data::Group")} };

    my @all_events;
    my %grouped_services;
    for my $service (@$services) {
        push @{$grouped_services{$service->group ? $service->group->id : ""}}, $service;

        my $events = [
            @{$db->match(
                class => "TownCrier::Data::Event", service => $service->id,
                { sort => sub { my ($a, $b) = @_; $b->ordered_compare($a) } }
            ) }
        ];
        push @all_events, @$events;

        $service->status($default_status) unless $service->status;

        my %events_by_day;
        push(@{$events_by_day{$_->timestamp->ymd}}, $_) for @$events;

        my @history;

        my $prev_day_status = do {
            my $prev_day = $days[-1]->{date}->clone;
            $prev_day->add(days => -1);
            exists $events_by_day{$prev_day->ymd} ? $events_by_day{$prev_day->ymd}->[0]->status : $default_status;
        };

        for my $day (reverse @days) {
            my $ymd = $day->{date}->ymd;
            my $info = 1;
            if (@{$events_by_day{$ymd} // []}) {
                $prev_day_status = $events_by_day{$ymd}->[0]->status;
                $info = 1;
            }
            else {
                $info = 0;
            }
            push @history, {
                date   => $ymd,
                today  => $day->{today},
                info   => $info,
                status => $prev_day_status,
            };
        }

        # XXX attribute
        $service->{history} = [ reverse @history ];
    }

    @all_events = sort { $b->ordered_compare($a) } @all_events;
    @all_events = splice @all_events, 0, 10;

    my $notices = [ grep { !$_->expired }
                    @{$db->match(class => "TownCrier::Data::Notice",
                                 { sort => sub { my ($a, $b) = @_; $b->ordered_compare($a) } })} ];

    template "index" => {
        _template_params,
        days => \@days,
        statuses => $statuses,
        services => $services,
        events => \@all_events,
        groups => $groups,
        grouped_services => \%grouped_services,
        notices => $notices,
    };
}

sub service {
    my $db = var 'db';
    my $service = $db->match(class => "TownCrier::Data::Service", id => params->{service})->[0];
    return status 'not_found' unless $service;

    my $date;
    if (params->{date}) {
        return status 'bad_request' unless params->{date} =~ m/^\d{4}-\d{2}-\d{2}$/;
        $date = DateTime::Format::DateParse->parse_datetime(params->{date});
    }

    my $statuses = $db->match(class => "TownCrier::Data::Status");

    my $events = $db->match(
        class => "TownCrier::Data::Event", service => $service->id,
        { sort => sub { my ($a, $b) = @_; $b->ordered_compare($a) } }
    );

    my $default_status = $db->match(
        class => "TownCrier::Data::Status",
        id => TOWNCRIER_DEFAULT_STATUS,
    )->[0];

    $service->status($default_status) unless $service->status;

    @$events = grep { $_->timestamp->ymd eq $date->ymd } @$events if $date;

    @$events = splice @$events, 0, 5;

    template "service", {
        _template_params,
        service => $service,
        statuses => $statuses,
        events => $events,
        date => $date,
    };
}

sub notices {
    my $db = var 'db';
    my $notices = $db->match(class => "TownCrier::Data::Notice",
                             { sort => sub { my ($a, $b) = @_; $b->ordered_compare($a) } });

    template "notices", {
        _template_params,
        notices => $notices,
    };
}

1;
