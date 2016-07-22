package WWW::Naver::SearchAd;

# ABSTRACT: bidding(?) for http://searchad.naver.com

use Moo;

use Digest::SHA qw(hmac_sha256_base64);
use HTTP::Tiny;
use JSON qw/encode_json/;
use Mojo::Log;
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
has log => ( is => 'ro', default => sub { Mojo::Log->new } );

=head1 METHODS

=head2 request

    my $res = $api->request($method, $path, $params?, $opts?);

=cut

sub request {
    my ( $self, $method, $path, $params, $opts ) = @_;

    my $url = $BASE_URL . $path;
    $url .= "?$params" if $params;
    $self->log->debug("--> Working on $method $url ... ");

    my $custom_headers = $self->custom_headers( $method, $path );
    if ($opts) {
        map { $opts->{headers}{$_} = $custom_headers->{$_} } keys %$custom_headers;
    }
    else {
        $opts = { headers => $custom_headers };
    }

    my $res = $self->http->request( $method, $url, $opts );

    unless ( $res->{success} ) {
        $self->log->error("Failed");
        $self->log->error("! $res->{reason}");
        $self->log->error("! $res->{content}");
        return;
    }

    $self->log->debug("OK");
    return $res;
}

=head2 campagins

    GET /ncc/campaigns{?baseSearchId,recordSize,selector}
    my $json = $api->campaigns(%attr);

=cut

sub campaigns {
    my ( $self, $attr ) = @_;

    ## TODO: $attr
    my $res = $self->request( 'GET', '/ncc/campaigns' );
    return unless $res;
    return $res->{content};
}

=head2 adgroups($campaignId)

    GET /ncc/adgroups{?nccCampaignId,baseSearchId,recordSize,selector}
    my $json = $api->adgroups($ids);

=cut

sub adgroups {
    my ( $self, $campaignId ) = @_;

    return unless $campaignId;

    my $params = $self->http->www_form_urlencode( { nccCampaignId => $campaignId } );
    my $res = $self->request( 'GET', '/ncc/adgroups', $params );
    return unless $res;
    return $res->{content};
}

=head2 keywords($ids)

    GET /ncc/keywords{?nccAdgroupId,baseSearchId,recordSize,selector}
    my $json = $api->keywords($ids);

=cut

sub keywords {
    my ( $self, $adgroupId ) = @_;

    return unless $adgroupId;

    my $params = $self->http->www_form_urlencode( { nccAdgroupId => $adgroupId } );
    my $res = $self->request( 'GET', '/ncc/keywords', $params );
    return unless $res;
    return $res->{content};
}

=head2 keyword($keywordId)

    GET /ncc/keywords/{nccKeywordId}
    my $json = $api->keyword($keywordId);

=cut

sub keyword {
    my ( $self, $keywordId ) = @_;

    return unless $keywordId;

    my $res = $self->request( 'GET', "/ncc/keywords/$keywordId" );
    return unless $res;
    return $res->{content};
}

=head2 update_keyword($bidAmt, $useGroupBidAmt, $adgroupId)

    PUT /ncc/keywords/{nccKeywordId}{?fields}
    my $json = $api->update_keyword(550, 'false', 'grp-m001-01-0000000000001');

=cut

sub update_keyword {
    my ( $self, $keywordId, $bidAmt, $useGroupBidAmt, $adgroupId ) = @_;

    return unless $keywordId;
    return unless $bidAmt;
    return unless $useGroupBidAmt;

    my $params = $self->http->www_form_urlencode( { fields => 'bidAmt' } );
    my $body = { bidAmt => $bidAmt, useGroupBidAmt => $useGroupBidAmt, nccAdgroupId => $adgroupId };
    my $opts = { headers => { 'content-type' => 'application/json' }, content => encode_json($body) };
    my $res = $self->request( 'PUT', "/ncc/keywords/$keywordId", $params, $opts );
    return unless $res;
    return $res->{content};
}

=head2 managedKeyword

    GET /ncc/managedKeyword{?keywords}
    my $json = $api->managedKeyword($keyword);

=cut

sub managedKeyword {
    my ( $self, $keyword ) = @_;

    return unless $keyword;

    my $params = $self->http->www_form_urlencode( { keywords => $keyword } );
    my $res = $self->request( 'GET', '/ncc/managedKeyword', $params );
    return unless $res;
    return $res->{content};
}

=head2 custom_headers

=cut

sub custom_headers {
    my ( $self, $method, $path ) = @_;
    my $epoch = int( gettimeofday * 1000 );
    my $signature = $self->signature( $epoch, $method, $path );

    return { 'X-Timestamp' => $epoch, 'X-Signature' => $signature };
}

=head2 signature

=cut

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
