package WWW::Naver::SearchAd;

# ABSTRACT: bidding(?) for http://searchad.naver.com

use Moo;

use Digest::SHA qw(hmac_sha256_base64);
use HTTP::Tiny;
use Time::HiRes qw(gettimeofday);

our $BASE_URL = 'https://api.naver.com';

has key         => ( is => 'ro', required => 1 );
has secret      => ( is => 'ro', required => 1 );
has customer_id => ( is => 'ro', required => 1 );
has http        => (
    is      => 'lazy',
    default => sub {
        my $self = shift;
        return HTTP::Tiny->new( default_headers => { 'X-API-KEY' => $self->key, 'X-Customer' => $self->customer_id } );
    }
);

=head1 METHODS

=head2 request

    my $data = $api->request('GET', '/ncc/campaigns');

=cut

sub request {
    my ( $self, $method, $path ) = @_;

    print STDERR "--> Working on $method $path ... ";

    my $res
        = $self->http->request( $method, $BASE_URL . $path, { headers => $self->custom_headers( $method, $path ) } );

    unless ( $res->{success} ) {
        print STDERR "Failed\n";
        print STDERR "! $res->{reason}\n";
        print STDERR "! $res->{content}\n";
        return;
    }

    print STDERR "OK\n";
    return $res->{content};
}

=head2 campagins

    https://api.naver.com/ncc/campaigns
    my $data = $api->campaigns(%attr);

=cut

sub campaigns {
    my ( $self, $attr ) = @_;

    ## TODO: $attr
    return $self->request( 'GET', '/ncc/campaigns' );
}

sub custom_headers {
    my ( $self, $method, $path ) = @_;
    my $epoch = int( gettimeofday * 1000 );
    my $signature = $self->signature( $epoch, $method, $path );

    return { 'X-Timestamp' => $epoch, 'X-Signature' => $signature };
}

sub signature {
    my ( $self, $epoch, $method, $path ) = @_;

    my $secret = $self->secret;
    my $data   = "$epoch.$method.$path";
    my $digest = hmac_sha256_base64( $data, $secret );
    while ( length($digest) % 4 ) {
        $digest .= '=';
    }

    return $digest;
}

1;

=pod

=encoding utf-8

=head1 NAME

WWW::Naver::SearchAd - bidding(?) for http://searchad.naver.com

=head1 SYNOPSIS

=cut
