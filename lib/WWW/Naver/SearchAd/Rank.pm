package WWW::Naver::SearchAd::Rank;

use HTTP::Tiny;

require Exporter;
@ISA       = qw(Exporter);
@EXPORT_OK = qw(find_rank);

our $BASE_URL = 'http://ad.search.naver.com/search.naver';

sub find_rank {
    my ( $keyword, $find ) = @_;
    return unless $find;
    return unless $keyword;

    my $http = HTTP::Tiny->new(
        agent           => 'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.04',
        default_headers => { accept => '*/*' }
    );
    my $params = $http->www_form_urlencode( { query => $keyword, where => 'ad', ie => 'utf8' } );
    my $url = "$BASE_URL?$params";

    print STDERR "--> Working on $url ... ";

    my $res = $http->get($url);

    unless ( $res->{success} ) {
        print STDERR "Failed\n";
        print STDERR "! $res->{reason}\n";
        return;
    }

    print STDERR "OK\n";

    my $content = $res->{content};
    my $rank    = 1;
    while ( $content =~ m{<a class="url"[^>]+>(.*)</a>}gc ) {
        return $rank if $1 eq $find;
        print "! $1\n";
        $rank++;
    }

    return;
}

1;
