package SearchAd::Web::Plugin::Helpers;

use Mojo::Base 'Mojolicious::Plugin';

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
}

=head1 HELPERS

=head1 COPYRIGHT

The MIT License (MIT)

Copyright (c) 2016 Hyungsuk Hong

=cut

1;
