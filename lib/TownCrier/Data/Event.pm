package TownCrier::Data::Event;

use Moo;
use Types::Standard -all;
use Type::Utils qw(class_type);
use DateTime;

with qw(KiokuDB::Role::ID KiokuDB::Role::UUIDs TownCrier::Role::Indexable TownCrier::Role::RESTful);

has service => ( is => 'rw', isa => class_type("TownCrier::Data::Service"), required => 1 );
has status => ( is => 'rw', isa => class_type("TownCrier::Data::Status"), required => 1 );
has message => ( is => 'rw', isa => Str, required => 1);

has timestamp => ( is => 'ro', isa => class_type("DateTime"), default => sub { DateTime->now } );

has id => ( is => 'lazy', isa => Str );
sub _build_id { shift->generate_uuid };
sub kiokudb_object_id { shift->id };

sub url {
    my ($self) = @_;
    "/services/".$self->service->id."/events/".$self->id
}

sub ordered_compare {
    my ($self, $other) = @_;
    return $self->timestamp->compare($other->timestamp);
}

sub extract_index {
    my ($self) = @_;
    return {
        id      => $self->id,
        service => $self->service->id,
    };
}

sub rest {
    my ($self) = @_;
    return {
        id        => $self->id,
        url       => $self->url,
        status    => $self->status->rest,
        message   => $self->message,
        timestamp => $self->timestamp->iso8601 . 'Z',
    };
}

1;
