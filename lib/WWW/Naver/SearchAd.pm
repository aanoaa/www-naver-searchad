package WWW::Naver::SearchAd;
# ABSTRACT: bidding(?) for http://searchad.naver.com

use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request;
use HTTP::Request::Common;

use JSON::XS;
use Try::Tiny;

my $HOST    = 'searchad.naver.com';
my $REFERER = "http://$HOST";

sub new {
    my ($class, $args) = @_;

    my $ua = LWP::UserAgent->new(
        agent => $args->{agent} || 'Mozilla/5.0 (X11; Linux x86_64; rv:10.0.11) Gecko/20100101 Firefox/10.0.11 Iceweasel/10.0.11'
    );

    push @{ $ua->requests_redirectable }, 'POST';
    $ua->cookie_jar(HTTP::Cookies->new);
    $ua->add_handler(
        'request_prepare' => sub {
            my ($req, $ua, $h) = @_;
            print $req->as_string, "\n" if $ENV{DEBUG};
        }
    );

    $ua->add_handler(
        'response_done' => sub {
            my ($res, $ua, $h) = @_;
            print $res->as_string, "\n" if $ENV{DEBUG};
        }
    );

    return bless {
        agent => $ua
    }, $class;
}

sub signin {
    my ($self, $username, $password) = @_;

    delete $self->{error};
    if (!$username || !$password) {
        $self->{error} = 'signin failed: no username or password';
        return;
    }

    my $ua  = $self->{agent};
    my $res = $ua->request(
        POST "https://$HOST/Login/login.json",
        Referer => $REFERER,
        Content => [
            loginId  => $username,
            loginPwd => $password
        ]
    );

    if (!$res->is_success) {
        $self->{error} = $res->status_line;
        return;
    }

    my $data = try {
        decode_json($res->content);
    } catch {
        $self->{error} = "failed to decode_json: $_";
        return;
    };

    if ($data->{retCode} != 0) {
        $self->{error} = $data->{retMsg};
        return;
    }

    return $res->code;
}

sub get_bundles {
    my $self = shift;

    my $ua = $self->{agent};
    my $res = $ua->request(GET "http://$HOST/AMCC30/AMCC3001_A01.nbp");

    if (!$res->is_success) {
        $self->{error} = $res->status_line;
        return;
    }

    my $body = $res->content;
    my ($json) = $body =~ m/bundleList: (.*?),?\r\n/s;

    unless ($json) {
        $self->{error} = "Couldn't find bundleList";
        return;
    }

    my $data = try {
        decode_json($json);
    } catch {
        $self->{error} = "failed to decode_json: $_";
        return;
    };

    return $data;
}

sub refresh {
    my ($self, $bundle_id, $rank, $limit) = @_;

    delete $self->{error};
    if (!$bundle_id || !$rank) {
        $self->{error} = "wrong arguments";
        return;
    }

    my $data = $self->_get_bundle_data($bundle_id);
    return if $self->{error};

    my $params = $self->_set_prices_by_rank($data, $rank, $limit);
    return if $self->{error};

    $self->_apply_prices($params);
    return if $self->{error};

    return 1;
}

sub _get_bundle_data {
    my ($self, $bundle_id) = @_;

    my $ua = $self->{agent};
    my $res = $ua->request(
        POST "http://$HOST/AMCC30/AMCC3001_A02.json",
        [
            bundleId => $bundle_id
        ]
    );

    if (!$res->is_success) {
        $self->{error} = $res->status_line;
        return;
    }

    my $data = try {
        decode_json($res->content);
    } catch {
        $self->{error} = "failed to decode_json: $_";
        return;
    };

    if ($data->{retCode} != 0) {
        $self->{error} = $data->{retMsg};
        return;
    }

    return $data;
}

sub _set_prices_by_rank {
    my ($self, $decoded_data, $rank, $limit) = @_;

    my %params;
    my $i = 0;
    for my $item (@{ $decoded_data->{cpcReqList} }) {
        $params{"cpcReqList[$i][rowId]"} = 'r' . (0 + $i);
        map { $params{"cpcReqList[$i][$_]"} = $item->{$_} } qw/urlId cpcGroupId cpcReqId keywordId keyword restrictType bidAmt isNxRestricted/;

        $i++;
    }

    my $ua  = $self->{agent};
    my $res = $ua->request(
        POST "http://$HOST/AMCC23/AMCC2302_A04.json",
        [
            bidAmt => $limit || '100000',
            rank   => $rank,
            %params,
        ]
    );

    if (!$res->is_success) {
        $self->{error} = $res->status_line;
        return;
    }

    my $data = try {
        decode_json($res->content);
    } catch {
        $self->{error} = "failed to decode_json: $_";
        return;
    };

    if ($data->{retCode} != 0) {
        $self->{error} = $data->{retMsg};
        return;
    }

    $i = 0;
    for my $item (@{ $data->{rankCpcList} }) {
        $params{"cpcReqList[$i][bidAmt]"} = $item->{bidAmt};
        delete $params{"cpcReqList[$i][isNxRestricted]"};

        $i++;
    }

    return \%params;
}

sub _apply_prices {
    my ($self, $params) = @_;

    my $ua  = $self->{agent};
    my $res = $ua->request(
        POST "http://$HOST/AMCC30/AMCC3001_A09.json",
        Referer => $REFERER,
        Content => [ %$params ]
    );

    if (!$res->is_success) {
        $self->{error} = $res->status_line;
        return;
    }

    my $data = try {
        decode_json($res->content);
    } catch {
        $self->{error} = "failed to decode_json: $_";
        return;
    };

    if ($data->{retCode} != 0) {
        $self->{error} = $data->{retMsg};
        return;
    }

    return $res->code;
}

1;

=pod

=head1 NAME

WWW::Naver::SearchAd - bidding(?) for http://searchad.naver.com

=head1 SYNOPSIS

    $ node salogin.js `password`    # requires node
    # 99fc288bed... is used as a password for signin

    use WWW:Naver::SearchAd;
    my $ad = WWW:Naver::SearchAd->new;
    die $ad->{error} unless $ad->signin('username', '99fc288bed...');

    my $bundle_id = '11111';

    my $rank      = 11
    # 1  .. 10 : Power1 .. Power10
    # 11 .. 15 : Biz1 .. Biz5

    die $ad->{error} unless $ad->refresh($bundle_id, $rank);


    $ export DEBUG=1    # for debugging HTTP Messages

=head1 DESCRIPTION

no description yet.

=cut
