package TownCrier::Data::Service;

use Moo;
use Types::Standard -all;
use Type::Utils qw(class_type);

with qw(TownCrier::Role::Indexable TownCrier::Role::RESTful);

has id => ( is => 'rw', isa => Str, required => 1);
has name => ( is => 'rw', isa => Str, required => 1);
has description => ( is => 'rw', isa => Str, required => 1);

has order => ( is => 'rw', isa => Int, default => 0 );

has status => ( is => 'rw', isa => class_type("TownCrier::Data::Status") );
has event => ( is => 'rw', isa => class_type("TownCrier::Data::Event") );

has group => ( is => 'rw', isa => class_type("TownCrier::Data::Group") );

sub url { "/services/".shift->id }

sub ordered_compare {
    my ($self, $other) = @_;
    # lower order wins
    return $self->order <=> $other->order unless ($self->order == $other->order);
    # then just by id
    return $self->id cmp $other->id;
}

sub extract_index {
    my ($self) = @_;
    return {
        id    => $self->id,
        $self->group ? (group => $self->group->id) : (),
    };
}

sub rest {
    my ($self) = @_;
    return {
        id           => $self->id,
        url          => $self->url,
        name         => $self->name,
        description  => $self->description,
        order        => $self->order,
        status       => $self->status ? $self->status->rest : undef,
        event        => $self->event ? $self->event->rest : undef,
        group        => $self->group ? $self->group->rest : undef,
    };
}

1;

