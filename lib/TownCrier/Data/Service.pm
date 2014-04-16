package TownCrier::Data::Service;

use Moo;
use Types::Standard -all;
use Type::Utils qw(class_type);

with qw(TownCrier::Role::Indexable TownCrier::Role::RESTful);

has id => ( is => 'rw', isa => Str, required => 1);
has name => ( is => 'rw', isa => Str, required => 1);
has description => ( is => 'rw', isa => Str, required => 1);

has status => ( is => 'rw', isa => class_type("TownCrier::Data::Status") );
has event => ( is => 'rw', isa => class_type("TownCrier::Data::Event") );

sub url { "/services/".shift->id }

sub extract_index {
    my ($self) = @_;
    return {
        id => $self->id,
    };
}

sub rest {
    my ($self) = @_;
    return {
        id           => $self->id,
        url          => $self->url,
        name         => $self->name,
        description  => $self->description,
        status       => $self->status ? $self->status->rest : undef,
        event        => $self->event ? $self->event->rest : undef,
    };
}

1;

