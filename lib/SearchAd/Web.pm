package SearchAd::Web;
use Mojo::Base 'Mojolicious';

use SearchAd::Schema;

use version; our $VERSION = qv("v0.0.1");

has schema => sub {
    return SearchAd::Schema->connect(
        { dsn => "dbi:SQLite:db/searchad.db", quote_char => q{`}, sqlite_unicode => 1, } );
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
}

sub _assets {
    my $self = shift;

    $self->defaults( jses => [], csses => [] );
}

sub _public_routes {
    my $self = shift;
    my $r    = $self->routes;

    $r->get('/')->to('root#index');
}

sub _private_routes {
    my $self = shift;
    my $r    = $self->routes;
}

1;
