package SearchAd::Web::Controller::Adkeyword;
use Mojo::Base 'Mojolicious::Controller';

use Data::Pageset;
use Directory::Queue;
use WWW::Naver::SearchAd::Rank qw/enqueue/;

has schema => sub { shift->app->schema };
has dirq => sub { Directory::Queue->new( path => '/tmp/searchad' ) };

=head1 METHODS

=head2 adkeyword_id

    under /adkeywords/:adkeyword_id

=cut

sub adkeyword_id {
    my $self         = shift;
    my $adkeyword_id = $self->param('adkeyword_id');

    my $adkeyword = $self->schema->resultset('Adkeyword')->find( { id => $adkeyword_id } );
    unless ($adkeyword) {
        $self->error( 404, "Not found adkeyword: $adkeyword_id" );
        return;
    }

    $self->stash( adkeyword => $adkeyword );
    return 1;
}

=head2 adkeyword

    GET /adkeywords/:adkeyword_id

=cut

sub adkeyword {
    my $self      = shift;
    my $adkeyword = $self->stash('adkeyword');
    my $p         = $self->param('p') || 1;

    my $attr = { page => $p, rows => 20, order_by => { -desc => 'id' } };
    my $rs = $self->schema->resultset('Bidlog')->search( { adkeyword_id => $adkeyword->id }, $attr );

    my $pager   = $rs->pager;
    my $pageset = Data::Pageset->new(
        {
            total_entries    => $pager->total_entries,
            entries_per_page => $pager->entries_per_page,
            pages_per_set    => 5,
            current_page     => $p,
        }
    );

    $self->respond_to(
        html => { logs => $rs, pageset => $pageset },
        json => sub {
            my @logs;
            while ( my $log = $rs->next ) {
                push @logs, { $log->get_columns };
            }

            $self->render(
                json => { adkeyword => { $adkeyword->get_columns }, rank => { $adkeyword->rank->get_columns }, logs => \@logs } );
        }
    );
}

=head2 update_adkeyword

    PUT /adkeywords/:adkeyword_id

=cut

sub update_adkeyword {
    my $self      = shift;
    my $adkeyword = $self->stash('adkeyword');

    enqueue( $self->dirq, $adkeyword->rank );
    $self->render( json => { $adkeyword->get_columns } );
}

1;
