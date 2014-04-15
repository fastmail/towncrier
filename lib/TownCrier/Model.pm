package TownCrier::Model;

use Moo;
use Search::GIN::Extract::Multiplex;
use Search::GIN::Extract::Class;
use Search::GIN::Extract::Callback;
use Search::GIN::Query::Manual;
use Scalar::Util qw(blessed);

extends "KiokuX::Model";

sub BUILDARGS {
    my ($class, %args) = @_;

    $args{extra_args} //= {};

    $args{extra_args}{create} //= 1;

    $args{extra_args}{extract} //=
        Search::GIN::Extract::Multiplex->new(
            extractors => [
                Search::GIN::Extract::Class->new,
                Search::GIN::Extract::Callback->new(
                    extract => sub {
                        my ($obj, @args) = @_;
                        return $obj->extract_index(@args)
                            if $obj->does("TownCrier::Role::Indexable");
                        return;
                    },
                ),
            ],
        );

    return \%args;
}

sub match {
    my ($self, @args) = @_;

    my $opts = ref $args[-1] ? pop @args : {};
    my %values = @args;

    my $class = delete $values{class};

    my $stream;
    if (!%values) {
        $stream = $self->search({class => $class});
    }
    else {
        $stream = $self->search(Search::GIN::Query::Manual->new(
            values => {
                %values,
                defined $class ? ( class => $class ) : (),
            },
            filter => sub {
                my ($obj) = @_;
                (!defined $class || blessed $obj eq $class) &&
                (grep { $obj->can($_) &&
                    ((blessed $obj->$_ && $obj->$_->id eq $values{$_}) ||
                    $obj->$_ eq $values{$_}) } keys %values) == scalar keys %values
            },
        ));
    }

    if ($opts->{sort}) {
        return [ sort { $opts->{sort}($a,$b) } $stream->all ];
    }

    return [ $stream->all ];
}

1;
