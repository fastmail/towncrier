package TownCrier::Handler::API::Notice;

use TownCrier::Data;
use Dancer qw(params status var);

sub list {
    my $db = var 'db';
    { notices => [ map { $_->rest }
                   @{$db->match(class => "TownCrier::Data::Notice",
                                { sort => sub { my ($a, $b) = @_; $b->ordered_compare($a) } })} ] }
}

sub post {
    my $db = var 'db';

    my @params = @{params()}{qw(message)};
    return status 'bad_request' unless @params == 1;
    my ($message) = @params;

    my $notice = TownCrier::Data::Notice->new(
        message => $message,
        params->{expiry} ? (expiry => DateTime::Format::ISO8601->parse_datetime(params->{expiry})) : (),
    );
    $db->store($notice);

    status 'created';
    return $notice->rest;
}

sub get {
    my $db = var 'db';

    my $notice = $db->match(class => "TownCrier::Data::Notice", id => params->{notice})->[0];
    return status 'not_found' unless $notice;

    return $notice->rest;
}

sub delete {
    my $db = var 'db';

    my $notice = $db->match(class => "TownCrier::Data::Notice", id => params->{notice})->[0];
    return status 'not_found' unless $notice;

    $db->delete($notice);
    return status 'ok';
}

1;
