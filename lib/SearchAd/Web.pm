package SearchAd::Web;
use Mojo::Base 'Mojolicious';

use Email::Valid ();
use SearchAd::Schema;

use version; our $VERSION = qv("v0.0.1");

has schema => sub {
    return SearchAd::Schema->connect(
        {
            dsn            => "dbi:SQLite:db/searchad.db",
            quote_char     => q{`},
            sqlite_unicode => 1,
        }
    );
};

=head1 METHODS

=head2 startup

This method will run once at server start

=cut

sub startup {
    my $self = shift;

    $self->plugin('Config');
    $self->plugin('SearchAd::Web::Plugin::Helpers');

    $self->secrets( $self->config->{secrets} );
    $self->sessions->cookie_name('searchad');
    $self->sessions->default_expiration(86400);

    $self->_assets;
    $self->_public_routes;
    $self->_private_routes;
    $self->_extend_validator;
}

sub _assets {
    my $self = shift;

    $self->defaults( jses => [], csses => [] );
}

sub _public_routes {
    my $self = shift;
    my $r    = $self->routes;

    $r->get('/welcome')->to('root#welcome');
    $r->get('/signin')->to('user#add');
    $r->post('/signin')->to('user#create');
    $r->get('/login')->to('user#login_form');
    $r->post('/login')->to('user#login');
    $r->get('/logout')->to('user#logout');
}

sub _private_routes {
    my $self = shift;
    my $root = $self->routes;

    my $r        = $root->under('/')->to('user#auth');
    my $adgroups = $root->under('/adgroups')->to('user#auth');

    $r->get('/')->to('root#index');
    $r->get('/profile')->to('user#profile');
    $r->post('/profile')->to('user#update_profile');

    my $adgroup = $adgroups->under('/:adgroup_id')->to('adgroup#adgroup_id');
    $adgroup->get('/')->to('adgroup#adgroup');
}

sub _extend_validator {
    my $self = shift;

    $self->validator->add_check(
        email => sub {
            my ( $v, $name, $value ) = @_;
            return not Email::Valid->address($value);
        }
    );
}

1;
