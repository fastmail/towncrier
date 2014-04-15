package TownCrier::Handler::API::Service;

use TownCrier::Data;
use Text::Slugify qw(slugify);
use Dancer qw(params status var);

sub list {
    my $db = var 'db';
    { services => [ map { $_->rest } @{$db->match(class => "TownCrier::Data::Service") } ] }
}

sub post {
    my $db = var 'db';

    my @params = @{params()}{qw(name description)};
    return status 'bad_request' unless @params == 2;
    my ($name, $description) = @params;

    my $id = slugify($name);

    my $service = $db->match(class => "TownCrier::Data::Service", id => $id)->[0];
    return status 'conflict' if $service;

    $service = TownCrier::Data::Service->new(
        id => $id,
        name => $name,
        description => $description,
    );
    $db->store($service);

    status 'created';
    return $service->rest;
}

sub get {
    my $db = var 'db';
    my $service = $db->match(class => "TownCrier::Data::Service", id => params->{service})->[0];
    return $service->rest if $service;
    return status 'not_found';
}

sub delete {
    my $db = var 'db';
    my $service = $db->match(class => "TownCrier::Data::Service", id => params->{service})->[0];
    return status 'not_found' unless $service;
    $db->delete($service);
    return status 'ok';
}

1;
