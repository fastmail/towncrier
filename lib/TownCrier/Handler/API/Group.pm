package TownCrier::Handler::API::Group;

use TownCrier::Data;
use Text::Slugify qw(slugify);
use Dancer qw(params status var);

sub list {
    my $db = var 'db';
    { groups => [ map { $_->rest } @{$db->match(class => "TownCrier::Data::Group") } ] }
}

sub post {
    my $db = var 'db';

    my @params = @{params()}{qw(name)};
    return status 'bad_request' unless @params == 1;
    my ($name) = @params;

    my $id = slugify(params->{id} // $name);

    my $group = $db->match(class => "TownCrier::Data::Group", id => $id)->[0];
    return status 'conflict' if $group;

    $group = TownCrier::Data::Group->new(
        id => $id,
        name => $name,
    );
    $db->store($group);

    status 'created';
    return $group->rest;
}

sub get {
    my $db = var 'db';
    my $group = $db->match(class => "TownCrier::Data::Group", id => params->{group})->[0];
    return $group->rest if $group;
    return status 'not_found';
}

sub delete {
    my $db = var 'db';
    my $group = $db->match(class => "TownCrier::Data::Group", id => params->{group})->[0];
    return status 'not_found' unless $group;
    $db->delete($group);
    return status 'ok';
}

sub list_services {
    my $db = var 'db';
    my $group = $db->match(class => "TownCrier::Data::Group", id => params->{group})->[0];
    return status 'not_found' unless $group;
    { services => [ map { $_->rest } @{$db->match(class => "TownCrier::Data::Service", group => $group->id) } ] }
}

1;
