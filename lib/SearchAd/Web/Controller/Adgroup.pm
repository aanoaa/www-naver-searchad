package SearchAd::Web::Controller::Adgroup;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON qw/decode_json/;

has schema => sub { shift->app->schema };

=head1 METHODS

=head2 adgroup_id

    under /adgroups/:adgroup_id

=cut

sub adgroup_id {
    my $self       = shift;
    my $adgroup_id = $self->param('adgroup_id');

    my $adgroup = $self->schema->resultset('Adgroup')->find( { id => $adgroup_id } );
    unless ($adgroup) {
        $self->error( 404, "Not found adgroup: $adgroup_id" );
        return;
    }

    $self->stash( adgroup => $adgroup );
    return 1;
}

=head2 adgroup

    GET /adgroups/:adgroup_id

=cut

sub adgroup {
    my $self    = shift;
    my $adgroup = $self->stash('adgroup');

    $self->stash( ranks => undef );
    my $keyword_rs = $self->schema->resultset('Adkeyword');
    my $rs = $keyword_rs->search( { adgroup_id => $adgroup->id } );
    return $self->render( adkeywords => $rs ) if $rs->count;

    my $api = $self->api;
    return $self->render unless $api;

    my $keywords = decode_json( $api->keywords( $adgroup->str_id ) );
    for my $hashref (@$keywords) {
        # 현재 금액의 반땅 더하고 뺀다, 현재 금액의 10%
        my $rank = $self->schema->resultset('Rank')->create(
            {
                bid_min      => $hashref->{bidAmt} - $hashref->{bidAmt} / 2,
                bid_max      => $hashref->{bidAmt} + $hashref->{bidAmt} / 2,
                bid_interval => $hashref->{bidAmt} / 10,
                bid_amt      => $hashref->{bidAmt},
            }
        );
        my $keyword = $keyword_rs->create(
            {
                adgroup_id => $adgroup->id,
                rank_id    => $rank->id,
                str_id     => $hashref->{nccKeywordId},
                name       => $hashref->{keyword},
            }
        );
    }

    $rs = $keyword_rs->search( { adgroup_id => $adgroup->id } );
    $self->render( adkeywords => $rs );
}

1;
