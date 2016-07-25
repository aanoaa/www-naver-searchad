package WWW::Naver::SearchAd::Rank;

use Encode qw/decode_utf8/;
use Gzip::Faster qw/gunzip/;
use HTTP::Tiny;
use IO::Socket::Socks::Wrapper qw(wrap_connection);
use Mojo::Log;

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

    my $agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.82 Safari/537.36';
    my $default_headers = {
        accept            => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language' => 'ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4',
        'Accept-Encoding' => 'gzip, deflate',
        'DNT'             => 1,
        'Cookie' =>
            'NNB=7PIBCDEKKANVO; _ga=GA1.2.1182011555.1462856106; _naver_usersession_=Q8wEtNIduh/XBMdIADI8Ng==; npic=/B/V6gSRDBZ4wrEXxGYyS6di4cd3EiAGdja1uzl9SL9DVotIP2cJ/vnAEMEKx8f8CA==; s1%3D535E%2Cs2%3DB981%2Cac%3D8169; nx_ssl=2; SHUnvsoRR2dssbeXfndssssssul-194517',
        'Referer' => 'http://www.naver.com/',
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
        $log->error("! $socks") if $socks;
        return ( $res->{success}, 0 );
    }

    $log->debug("OK: $keyword");
    $log->debug("$socks") if $socks;

    my $content = gunzip( $res->{content} );
    $content = decode_utf8( $res->{content} );
    my $rank = 1;
    while ( $content =~ m{<a class="lnk_url"[^>]+>(.*)</a>}gc ) {
        my $url = $1;
        return ( $res->{success}, $rank ) if $url eq $find;
        $rank++;
    }

    return ( $res->{success}, 0 );
}

=head2 enqueue($dirq, $rank, $socks?)

TODO: return code 를 정의하자

=cut

sub enqueue {
    my ( $dirq, $r, $socks ) = @_;

    return 100 unless $dirq;
    return 100 unless $r;   # $r is SearchAd::Schema::Result::Rank

    my $tobe = $r->tobe;
    my $max  = $r->bid_max;
    my $min  = $r->bid_min;
    my $int  = $r->bid_interval;
    my $amt  = $r->bid_amt;

    return 100 unless $tobe or $max or $min or $int or $amt;

    my $adkeyword = $r->adkeyword;
    my $adgroup   = $adkeyword->adgroup;
    my $campaign  = $adgroup->campaign;
    my $user      = $campaign->user;
    my $url       = $adgroup->target->url;
    $url =~ s{^https?://}{};
    my ( $success, $rank ) = find_rank( $adkeyword->name, $url, $socks );
    $r->update( { rank => $rank } );
    return unless $success;
    return 100 if $rank == $tobe;

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
    return 200;
}

1;
