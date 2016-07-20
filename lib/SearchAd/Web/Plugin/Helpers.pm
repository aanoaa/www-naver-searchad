package SearchAd::Web::Plugin::Helpers;

use Mojo::Base 'Mojolicious::Plugin';

use WWW::Naver::SearchAd;

=encoding utf8

=head1 NAME

SearchAd::Web::Plugin::Helpers - searchad web mojo helper

=head1 SYNOPSIS

    # Mojolicious::Lite
    plugin 'SearchAd::Web::Plugin::Helpers';

    # Mojolicious
    $self->plugin('SearchAd::Web::Plugin::Helpers');

=cut

sub register {
    my ( $self, $app, $conf ) = @_;

    $app->helper( log => sub { shift->app->log } );
    $app->helper( error => \&error );
    $app->helper( api   => \&api );
}

=head1 HELPERS

=head2 log

shortcut for C<$self-E<gt>app-E<gt>log>

    $self->app->log->debug('message');    # OK
    $self->log->debug('message');         # OK, shortcut

=head2 error( $status, $error )

    get '/foo' => sub {
        my $self = shift;
        my $required = $self->param('something');
        return $self->error(400, 'Failed to validate') unless $required;
    } => 'foo';

=cut

sub error {
    my ( $self, $status, $error ) = @_;

    $self->log->error($error);

    no warnings 'experimental';
    my $template;
    given ($status) {
        $template = 'bad_request' when 400;
        $template = 'unauthorized' when 401;
        $template = 'not_found' when 404;
        $template = 'exception' when 500;
        default { $template = 'unknown' }
    }

    $self->respond_to(
        json => { status => $status, json => { error => $error || q{} } },
        html => { status => $status, error => $error || q{}, template => $template },
    );

    return;
}

=head2 api

    my $json = $self->api->campaigns;

=cut

sub api {
    my $self = shift;
    my $user = $self->stash('user');
    return unless $user;
    return unless $user->customer_id or $user->api_key or $user->api_secret;

    return WWW::Naver::SearchAd->new(
        customer_id => $user->customer_id,
        key         => $user->api_key,
        secret      => $user->api_secret
    );
}

=head1 COPYRIGHT

The MIT License (MIT)

Copyright (c) 2016 Hyungsuk Hong

=cut

1;
