package TownCrier::Handler::API::Status;

use TownCrier::Data;
use Text::Slugify qw(slugify);
use Dancer qw(params status var);

sub list {
    my $db = var 'db';
    { statuses => [ map { $_->rest } @{$db->match(class => "TownCrier::Data::Status") } ] }
}

sub post {
    my $db = var 'db';

    my @params = @{params()}{qw(name description icon)};
    return status 'bad_request' unless @params == 3;
    my ($name, $description, $icon) = @params;

    my $id = slugify($name);

    my $status = $db->match(class => "TownCrier::Data::Status", id => $id)->[0];
    return status 'conflict' if $status;

    $status = TownCrier::Data::Status->new(
        id => $id,
        name => $name,
        description => $description,
        icon => $icon,
    );
    $db->store($status);

    status 'created';
    return $status->rest;
}

sub get {
    my $db = var 'db';
    my $status = $db->match(class => "TownCrier::Data::Status", id => params->{status})->[0];
    return $status->rest if $status;
    return status 'not_found';
}

sub delete {
    my $db = var 'db';
    my $status = $db->match(class => "TownCrier::Data::Status", id => params->{status})->[0];
    return status 'not_found' unless $status;
    $db->delete($status);
    return status 'ok';
}

1;
