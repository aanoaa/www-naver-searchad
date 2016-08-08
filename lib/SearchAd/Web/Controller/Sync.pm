package SearchAd::Web::Controller::Sync;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON qw/decode_json/;
use Try::Tiny;

has schema => sub { shift->app->schema };

=head1 METHODS

=head2 groups

    GET /sync/groups

=cut

sub groups {
    my $self = shift;
    my $user = $self->stash('user');

    my $api = $self->api;
    return $self->error( 403, 'Couldn not using API' ) unless $api;

    my $campaign_rs = $self->schema->resultset('Campaign');
    my $guard       = $self->schema->txn_scope_guard;
    my $campaigns   = decode_json( $api->campaigns || '[]' );
    try {
        for my $hashref (@$campaigns) {
            my $campaign = $campaign_rs->create_or_update(
                {
                    user_id => $user->id,
                    str_id  => $hashref->{nccCampaignId},
                    name    => $hashref->{name}
                }
            );

            my $adgroups = decode_json( $api->adgroups( $campaign->str_id ) );
            for my $hashref (@$adgroups) {
                my $target = $self->schema->resultset('Target')->find_or_create( { url => $hashref->{pcChannelKey} } );
                $self->schema->resultset('Adgroup')->create(
                    {
                        campaign_id => $campaign->id,
                        target_id   => $target->id,
                        str_id      => $hashref->{nccAdgroupId},
                        name        => $hashref->{name},
                    }
                );
            }
        }

        $guard->commit;
    }
    catch {
        chomp;
        $self->log->error($_);
    };
}

=head2 keywords

    GET /sync/keywords?adgroup_id=xxx

=cut

sub keywords {
}

1;
