package TownCrier::Handler::Site;

use TownCrier::Data;
use Dancer ':syntax';
use DateTime;
use DateTime::Format::DateParse;

sub _template_params {
    return (
        config => config->{towncrier} // {}
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

    my $services = $db->match(class => "TownCrier::Data::Service", $group_id ? (group => $group_id) : ());

    my $default_status = $db->match(
        class => "TownCrier::Data::Status",
        id => config->{towncrier}->{default_status}
    )->[0];

    my $today = DateTime->today;

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

    @all_events = sort { $b->{timestamp} cmp $a->{timestamp} } splice @all_events, 0, 10;

    template "index" => {
        _template_params,
        days => \@days,
        statuses => $statuses,
        services => $services,
        events => \@all_events,
        groups => $groups,
        grouped_services => \%grouped_services,
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
        id => config->{towncrier}->{default_status}
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

1;
