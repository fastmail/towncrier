package TownCrier::Data::Status;

use Moo;
use Types::Standard -all;

with qw(TownCrier::Role::Indexable TownCrier::Role::RESTful);

has id => ( is => 'rw', isa => Str, required => 1);
has name => ( is => 'rw', isa => Str, required => 1);
has description => ( is => 'rw', isa => Str, required => 1);
has icon => ( is => 'rw', isa => Str, required => 1);

sub url { "/statuses/".shift->id }

sub extract_index {
    my ($self) = @_;
    return {
        id => $self->id,
    };
}

sub rest {
    my ($self) = @_;
    return {
        id          => $self->id,
        url         => $self->url,
        name        => $self->name,
        description => $self->description,
        icon        => $self->icon,
    };
}

1;
