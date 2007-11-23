package CHI::t::Driver::CacheCache;
use CHI::Test;
use File::Temp qw(tempdir);
use strict;
use warnings;
use base qw(CHI::t::Driver);

my $root_dir;

sub new_cache_options {
    my $self = shift;

    $root_dir ||=
      tempdir( "chi-driver-cachecache-XXXX", TMPDIR => 1, CLEANUP => 1 );
    return (
        $self->SUPER::new_cache_options(),
        cc_class   => 'Cache::FileCache',
        cc_options => { root_dir => $root_dir }
    );
}

sub set_standard_keys_and_values {
    my ($self) = @_;

    my ( $keys, $values ) = $self->SUPER::set_standard_keys_and_values();

    # Cache::FileCache apparently cannot handle key = 0
    $keys->{'zero'} = 'zero';

    return ( $keys, $values );
}

1;
