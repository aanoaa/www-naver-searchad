package SearchAd::Web::Controller::Adgroup;
use Mojo::Base 'Mojolicious::Controller';

use Data::Pageset;
use Mojo::JSON qw/decode_json/;
use POSIX qw/ceil floor/;
use Try::Tiny;

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
    my $p       = $self->param('p') || 1;

    my $attr = { page => $p, rows => 20 };

    $self->stash( adkeywords => undef, pageset => undef );
    my $keyword_rs = $self->schema->resultset('Adkeyword');
    my $rs         = $keyword_rs->search( { adgroup_id => $adgroup->id }, $attr );
    my $pager      = $rs->pager;
    my $pageset    = Data::Pageset->new(
        {
            total_entries    => $pager->total_entries,
            entries_per_page => $pager->entries_per_page,
            pages_per_set    => 5,
            current_page     => $p,
        }
    );

    return $self->render( adkeywords => $rs, pageset => $pageset ) if $rs->count;

    my $api = $self->api;
    return $self->render unless $api;

    my $keywords = decode_json( $api->keywords( $adgroup->str_id ) );
    for my $hashref (@$keywords) {
        ## 현재 금액의 반땅 더하고 뺀다, 현재 금액의 10%
        my $half = floor( $hashref->{bidAmt} / 20 ) * 10;
        my $min  = $hashref->{bidAmt} - $half;
        my $max  = $hashref->{bidAmt} + $half;
        $min = 70 if $min < 70;
        my $rank = $self->schema->resultset('Rank')->create(
            {
                bid_min      => $min,
                bid_max      => $max,
                bid_interval => ceil( $hashref->{bidAmt} / 100 ) * 10,
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

    $rs      = $keyword_rs->search( { adgroup_id => $adgroup->id }, $attr );
    $pager   = $rs->pager;
    $pageset = Data::Pageset->new(
        {
            total_entries    => $pager->total_entries,
            entries_per_page => $pager->entries_per_page,
            pages_per_set    => 5,
            current_page     => $p,
        }
    );
    $self->render( adkeywords => $rs, pageset => $pageset );
}

=head2 update_ranks

    PUT /adgroups/:adgroup_id/ranks

=cut

sub update_ranks {
    my $self    = shift;
    my $adgroup = $self->stash('adgroup');

    my $v = $self->validation;
    $v->optional('tobe')->size( 1, 2 );
    $v->optional('on_off');
    $v->optional('bid_interval')->size( 2, 5 );

    if ( $v->has_error ) {
        my $failed = $v->failed;
        return $self->error( 400, 'Parameter Validation Failed: ' . join( ', ', @$failed ) );
    }

    my $input = $v->input;
    map { delete $input->{$_} } qw/name pk value/; # delete x-editable params

    my $guard = $self->schema->txn_scope_guard;
    my $ranks = $adgroup->adkeywords->search_related('rank');
    try {
        while ( my $rank = $ranks->next ) {
            $rank->update($input);
        }
        $guard->commit;
    }
    catch {
        chomp;
        $self->log->error($_);
    };

    $self->render( json => { $adgroup->get_columns } );
}

1;
