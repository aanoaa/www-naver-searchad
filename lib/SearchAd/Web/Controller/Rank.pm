package SearchAd::Web::Controller::Rank;
use Mojo::Base 'Mojolicious::Controller';

has schema => sub { shift->app->schema };

=head1 METHODS

=head2 update_rank

    PUT /ranks/:rank_id

=cut

sub update_rank {
    my $self    = shift;
    my $rank_id = $self->param('rank_id');

    my $rank = $self->schema->resultset('Rank')->find( { id => $rank_id } );
    return $self->error( 404, "Not found rank: $rank_id" ) unless $rank;

    my $v = $self->validation;
    $v->optional('bid_max')->size( 2, 5 );
    $v->optional('bid_min')->size( 2, 5 );
    $v->optional('bid_interval')->size( 2, 5 );
    $v->optional('tobe')->size( 1, 2 );
    $v->optional('rank')->size( 1, 2 );
    $v->optional('on_off');

    if ( $v->has_error ) {
        my $failed = $v->failed;
        return $self->error( 400, 'Parameter Validation Failed: ' . join( ', ', @$failed ) );
    }

    my $input = $v->input;
    map { delete $input->{$_} } qw/name pk value/; # delete x-editable params

    $rank->update($input);
    $self->render( json => { $rank->get_columns } );
}

1;
