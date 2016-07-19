package SearchAd::Web::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON qw/decode_json/;

has schema => sub { shift->app->schema };

=head1 METHODS

=head2 index

    GET /

=cut

sub index {
    my $self = shift;
    my $user = $self->stash('user');

    my $campaign_rs = $self->schema->resultset('Campaign');
    my $rs = $campaign_rs->search( { user_id => $user->id } );
    $self->stash( campaigns => $rs );
    return $self->render if $rs->count;

    my $api = $self->api;
    return $self->render unless $api;

    my $campaigns = decode_json( $api->campaigns );
    for my $hashref (@$campaigns) {
        my $campaign = $campaign_rs->create(
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

    $rs = $campaign_rs->search( { user_id => $user->id } );
    $self->render( campaigns => $rs );
}

1;
