package TownCrier::Util;

use warnings;
use strict;

use Exporter 'import';
our @EXPORT_OK = qw(slugify);

sub slugify {
    my ($text) = @_;
    $text =~ s/[^a-z0-9]+/-/gi;
    $text =~ s/^-?(.+?)-?$/$1/;
    $text =~ s/^(.+)$/\L$1/;
    return $text;
}

1;
