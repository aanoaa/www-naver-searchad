package SearchAd::Web::Controller::User;
use Mojo::Base 'Mojolicious::Controller';

use Digest::SHA qw(sha1_hex);

has schema => sub { shift->app->schema };

=head1 METHODS

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

    $self->session( login => $user->id );
    return $self->redirect_to('/');
}

=head2 logout

    GET /logout

=cut

sub logout {
    my $self = shift;

    delete $self->session->{login};
    $self->redirect_to('/welcome');
}

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

=head2 profile

    GET /profile

=cut

sub profile {
    my $self = shift;
    my $user = $self->stash('user');

    my $profile = $self->schema->resultset('Profile')->find( { user_id => $user->id } );
    $self->render( profile => $profile );
}

=head2 update_profile

    POST /profile

=cut

sub update_profile {
    my $self = shift;
    my $user = $self->stash('user');

    my $v = $self->validation;
    $v->required('customer-id');
    $v->required('api-key');
    $v->required('api-secret');

    if ( $v->has_error ) {
        my $failed = $v->failed;
        return $self->error( 400, 'Parameter Validation Failed: ' . join( ', ', @$failed ) );
    }

    my $customer_id = $v->param('customer-id');
    my $key         = $v->param('api-key');
    my $secret      = $v->param('api-secret');

    my $profile = $self->schema->resultset('Profile')->update_or_create(
        {
            user_id     => $user->id,
            customer_id => $customer_id,
            api_key     => $key,
            api_secret  => $secret,
        }
    );

    return $self->error( 500, "Couldn't create a new profile" ) unless $profile;
    $self->redirect_to('/profile');
}

1;
