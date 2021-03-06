package WWW::Naver::SearchAd::Rank;

use Encode qw/decode_utf8/;
use Gzip::Faster qw/gunzip/;
use HTTP::Tiny;
use IO::Socket::Socks::Wrapper qw(wrap_connection);
use JSON qw/decode_json/;
use Mojo::Log;
use WWW::Naver::SearchAd;

require Exporter;
@ISA       = qw(Exporter);
@EXPORT_OK = qw(find_rank enqueue $RANK_OK $RANK_UPDATED $RANK_ERR_ARG $RANK_ERR_BIZMONEY $RANK_ERR_FORBIDDEN);

our $BASE_URL = 'http://search.naver.com/search.naver';

our @USER_AGENT = (
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.7 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.7',
    'Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0',
    'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0',
    'Mozilla/5.0 (Windows NT 10.0; Trident/7.0; rv:11.0) like Gecko',
    'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.04',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.10240'
);

## error codes
our $RANK_OK            = 200;
our $RANK_UPDATED       = 201;
our $RANK_ERR_ARG       = 101;
our $RANK_ERR_BIZMONEY  = 102;
our $RANK_ERR_FORBIDDEN = undef;

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

    srand();
    my $rand            = int( rand( scalar @USER_AGENT ) );
    my $agent           = $USER_AGENT[$rand];
    my $default_headers = {
        accept            => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language' => 'ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4',
        'Accept-Encoding' => 'gzip, deflate',
        'DNT'             => 1,
        'Referer'         => 'http://www.naver.com/',
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
        $log->error("! Failed($res->{status}): $keyword");
        $log->error("! $res->{reason}");
        $log->error("! $socks") if $socks;
        return ( $res->{success}, 0 );
    }

    $log->debug("OK($res->{status}): $keyword");
    $log->debug("$socks") if $socks;

    my $content = gunzip( $res->{content} );
    $content = decode_utf8($content);
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

    return $RANK_ERR_ARG unless $dirq;
    return $RANK_ERR_ARG unless $r;   # $r is SearchAd::Schema::Result::Rank

    my $tobe = $r->tobe;
    my $max  = $r->bid_max;
    my $min  = $r->bid_min;
    my $int  = $r->bid_interval;
    my $amt  = $r->bid_amt;

    return $RANK_ERR_ARG unless $tobe or $max or $min or $int or $amt;

    my $adkeyword = $r->adkeyword;
    my $adgroup   = $adkeyword->adgroup;
    my $campaign  = $adgroup->campaign;
    my $user      = $campaign->user;
    my $url       = $adgroup->target->url;
    $url =~ s{^https?://}{};
    my ( $success, $rank ) = find_rank( $adkeyword->name, $url, $socks );
    $r->update( { rank => $rank } );
    return $RANK_ERR_FORBIDDEN unless $success;
    return $RANK_OK if $rank == $tobe;

    unless ($rank) {
        my $api = WWW::Naver::SearchAd->new(
            customer_id => $user->customer_id,
            key         => $user->api_key,
            secret      => $user->api_secret
        );

        my $json = $api->bizmoney;
        die "Failed to get a bizmoney" unless $json;

        my $data = decode_json($json);
        my $bizmoney = $data->{bizmoney} || 0;
        if ( $bizmoney <= 0 ) {
            $log->info("Not enough bizmoney: $bizmoney");
            return $RANK_ERR_BIZMONEY;
        }
    }

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
    return $RANK_UPDATED;
}

1;
