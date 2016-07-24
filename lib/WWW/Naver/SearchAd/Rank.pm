package WWW::Naver::SearchAd::Rank;

use Encode qw/decode_utf8/;
use HTTP::Tiny;
use Mojo::Log;
use IO::Socket::Socks::Wrapper qw(wrap_connection);

require Exporter;
@ISA       = qw(Exporter);
@EXPORT_OK = qw(find_rank enqueue);

our $BASE_URL = 'http://search.naver.com/search.naver';

my $log = Mojo::Log->new;

=head1 FUNCTIONS

=head2 find_rank($keyword, $find, $socks?)

    my ($is_success, $rank) = find_rank('제주도여행', 'www.jejudo.co.kr');
    my ($is_success, $rank) = find_rank('제주도여행', 'www.jejudo.co.kr', 'localhost:9150');    # use socks proxy

=cut

sub find_rank {
    my ( $keyword, $find, $socks ) = @_;
    return unless $find;
    return unless $keyword;

    my $agent           = 'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.04';
    my $default_headers = {
        accept            => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language' => 'en-US,en;q=0.5',
        'DNT'             => 1
    };

    my $http;
    if ($socks) {
        $log->debug("Socks proxy: $socks");
        my ( $addr, $port, $version ) = split /:/, $socks;
        $http = wrap_connection(
            HTTP::Tiny->new( agent => $agent, default_headers => $default_headers ),
            {
                ProxyAddr    => $addr,
                ProxyPort    => $port,
                SocksVersion => $version || 5,
                Timeout      => 15
            }
        );
    }
    else {
        $http = HTTP::Tiny->new( agent => $agent, default_headers => $default_headers );
    }

    my $params = $http->www_form_urlencode( { query => $keyword, where => 'ad', ie => 'utf8' } );
    my $url = "$BASE_URL?$params";

    $log->debug("--> Working on $BASE_URL?query=$keyword&where=ad&ie=utf8 ... ");

    my $res = $http->get($url);

    unless ( $res->{success} ) {
        $log->error("! Failed: $keyword");
        $log->error("! $res->{reason}");
        return ( $res->{success}, 0 );
    }

    $log->debug("OK: $keyword");

    my $content = decode_utf8( $res->{content} );
    my $rank    = 1;
    while ( $content =~ m{<a class="lnk_url"[^>]+>(.*)</a>}gc ) {
        my $url = $1;
        return ( $res->{success}, $rank ) if $1 eq $find;
        $rank++;
    }

    return ( $res->{success}, 0 );
}

sub enqueue {
    my ( $dirq, $r, $socks ) = @_;

    return unless $dirq;
    return unless $r;   # $r is SearchAd::Schema::Result::Rank

    my $tobe = $r->tobe;
    my $max  = $r->bid_max;
    my $min  = $r->bid_min;
    my $int  = $r->bid_interval;
    my $amt  = $r->bid_amt;

    return unless $tobe or $max or $min or $int or $amt;

    my $adkeyword = $r->adkeyword;
    my $adgroup   = $adkeyword->adgroup;
    my $campaign  = $adgroup->campaign;
    my $user      = $campaign->user;
    my $url       = $adgroup->target->url;
    $url =~ s{^https?://}{};
    my ( $success, $rank ) = find_rank( $adkeyword->name, $url, $socks );
    $r->update( { rank => $rank } );
    return unless $success;
    return if $rank == $tobe;

    $rank = $adkeyword->max_depth + 1 unless $rank;
    $int *= -1 if $rank < $tobe;

    my $distance = $tobe - $rank;
    $distance *= -1 if $distance < 0;
    $amt = $amt + $int * $distance;
    $amt = $min if $amt < $min;
    $amt = $max if $amt > $max;

    my $str = sprintf '%s:%s:%s:%s:%s', $r->id, $amt, $adkeyword->str_id, $adgroup->str_id, $user->id;
    my $msg = sprintf 'rank_id(%s):bidAmt(%s):keyword_id(%s):group_id(%s):user_id(%s)', $r->id, $amt, $adkeyword->str_id,
        $adgroup->str_id, $user->id;
    $log->debug($msg);
    $dirq->add($str);
}

1;
