package CHI::t::Driver::Paired;
use strict;
use warnings;
use base qw(CHI::t::Driver);

my ( $cache, $secondary_cache, $key, $value, $key2, $value2 );

sub set_standard_keys_and_values {
    my ($self) = @_;

    my ( $keys, $values ) = $self->SUPER::set_standard_keys_and_values();

    # keys for file driver have max length of 255 or so
    # but on windows xp, the full pathname is limited to 255 chars as well
    $keys->{'large'} = scalar( 'ab' x ( $^O eq 'MSWin32' ? 64 : 120 ) );

    return ( $keys, $values );
}

sub test_set_and_remove : Tests(100) {
    my ($self) = @_;
    ( $key, $value ) = $self->kvpair();
    $key2   = $key . "2";
    $value2 = $value . "2";

    $cache           = $self->{cache};
    $secondary_cache = $cache->secondary_subcache;

    my $test_remove_method = sub {
        my ( $desc, $remove_code ) = @_;
        $desc = "testing $desc";

        confirm_caches_empty("$desc: before set");
        $cache->set( $key,  $value );
        $cache->set( $key2, $value2 );
        confirm_caches_populated("$desc: after set");
        $remove_code->();

        confirm_caches_empty("$desc: before set_multi");
        $cache->set_multi( { $key => $value, $key2 => $value2 } );
        confirm_caches_populated("$desc: after set_multi");
        $remove_code->();
    };
    $test_remove_method->(
        'remove', sub { $cache->remove($key); $cache->remove($key2) }
    );
    $test_remove_method->(
        'expire', sub { $cache->expire($key); $cache->expire($key2) }
    );
    $test_remove_method->(
        'expire_if',
        sub {
            $cache->expire_if( $key,  sub { 1 } );
            $cache->expire_if( $key2, sub { 1 } );
        }
    );
    $test_remove_method->( 'clear', sub { $cache->clear() } );
}

sub confirm_caches_empty {
    my ($desc) = @_;
    ok( $cache->is_empty(),           "primary cache is empty - $desc" );
    ok( $secondary_cache->is_empty(), "secondary cache is empty - $desc" );
}

sub confirm_caches_populated {
    my ($desc) = @_;
    is( $cache->get($key), $value, "primary cache is populated - $desc" );
    is( $secondary_cache->get($key),
        $value, "secondary cache is populated - $desc" );
    is( $cache->get($key2), $value2, "primary cache is populated #2 - $desc" );
    is( $secondary_cache->get($key2),
        $value2, "secondary cache is populated #2 - $desc" );
}

1;
