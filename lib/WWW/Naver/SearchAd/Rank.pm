package WWW::Naver::SearchAd::Rank;

use Encode qw/decode_utf8/;
use HTTP::Tiny;
use Mojo::Log;

require Exporter;
@ISA       = qw(Exporter);
@EXPORT_OK = qw(find_rank);

our $BASE_URL = 'http://search.naver.com/search.naver';

my $log = Mojo::Log->new;

sub find_rank {
    my ( $keyword, $find ) = @_;
    return unless $find;
    return unless $keyword;

    my $http = HTTP::Tiny->new(
        agent           => 'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.04',
        default_headers => {
            accept            => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' => 'en-US,en;q=0.5',
            'DNT'             => 1
        }
    );
    my $params = $http->www_form_urlencode( { query => $keyword, where => 'ad', ie => 'utf8' } );
    my $url = "$BASE_URL?$params";

    $log->debug("--> Working on $url ... ");

    my $res = $http->get($url);

    unless ( $res->{success} ) {
        $log->error("Failed");
        $log->error("! $res->{reason}");
        return;
    }

    $log->debug("OK");

    my $content = decode_utf8( $res->{content} );
    my $rank    = 1;
    while ( $content =~ m{<a class="lnk_url"[^>]+>(.*)</a>}gc ) {
        my $url = $1;
        return $rank if $1 eq $find;
        $rank++;
    }

    return;
}

1;
