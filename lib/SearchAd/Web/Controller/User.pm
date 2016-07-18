package SearchAd::Web::Controller::User;
use Mojo::Base 'Mojolicious::Controller';

use Digest::SHA qw(sha1_hex);

has schema => sub { shift->app->schema };

=head1 METHODS

=head2 add

    GET /signin

=cut

sub add {
    my $self = shift;
}

=head2 create

    POST /signin

=cut

sub create {
    my $self = shift;

    my $v = $self->validation;
    $v->required('username');
    $v->required('password');
    $v->required('email')->email;

    if ( $v->has_error ) {
        my $failed = $v->failed;
        return $self->error( 400, 'Parameter Validation Failed: ' . join( ', ', @$failed ) );
    }

    my $username = $v->param('username');
    my $password = $v->param('password');
    my $email    = $v->param('email');

    my $salt = time;
    $password = sha1_hex( $password . $salt );

    my $user = $self->schema->resultset('User')->create(
        {
            username => $username,
            password => $password . $salt,
            email    => $email
        }
    );

    return $self->error( 500, 'Failed to create a new user' ) unless $user;

    $user->create_related( user_roles => { role_id => 1 } ); # 1 is 'user' role
    $self->session( 'login' => $user->id );
    $self->redirect_to('/');
}

=head2 auth

    under /

=cut

sub auth {
    my $self = shift;

    my $user_id = $self->session('login');
    unless ($user_id) {
        $self->redirect_to('/login');
        return;
    }

    my $user = $self->schema->resultset('User')->find( { id => $user_id } );
    unless ($user) {
        $self->error( 500, "Couldn't find a user: $user_id" );
        return;
    }

    $self->stash( user => $user );
    return 1;
}

=head2 login_form

    GET /login

=cut

sub login_form { }

=head2 login

    POST /login

=cut

sub login {
    my $self = shift;

    my $v = $self->validation;
    $v->required('username');
    $v->required('password');

    if ( $v->has_error ) {
        my $failed = $v->failed;
        return $self->error( 400, 'Parameter Validation Failed: ' . join( ', ', @$failed ) );
    }

    my $username = $v->param('username');
    my $password = $v->param('password');

    my $user = $self->schema->resultset('User')->find( { username => $username } );
    return $self->error( 404, "User not found: $username" ) unless $user;

    my $salt = substr $user->password, 40;
    if ( $user->password ne sha1_hex( $password . $salt ) . $salt ) {
        return $self->error( 401, 'Authorization failed: wrong password' );
    }

    return $self->redirect_to('/');
}

=head2 logout

    # logout
    GET /logout

=cut

sub logout {
    my $self = shift;

    delete $self->session->{login};
    $self->redirect_to('/');
}

1;
