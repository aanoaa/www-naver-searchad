use utf8;
package SearchAd::Schema::Result::Bidlog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SearchAd::Schema::Result::Bidlog

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<SearchAd::Schema::Base>

=cut

use base 'SearchAd::Schema::Base';

=head1 TABLE: C<bidlog>

=cut

__PACKAGE__->table("bidlog");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 adkeyword_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 before_amt

  data_type: 'integer'
  is_nullable: 0

=head2 after_amt

  data_type: 'integer'
  is_nullable: 0

=head2 rank

  data_type: 'integer'
  is_nullable: 0

=head2 create_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  inflate_datetime: 1
  is_nullable: 1
  set_on_create: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "adkeyword_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "before_amt",
  { data_type => "integer", is_nullable => 0 },
  "after_amt",
  { data_type => "integer", is_nullable => 0 },
  "rank",
  { data_type => "integer", is_nullable => 0 },
  "create_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    inflate_datetime => 1,
    is_nullable => 1,
    set_on_create => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 adkeyword

Type: belongs_to

Related object: L<SearchAd::Schema::Result::Adkeyword>

=cut

__PACKAGE__->belongs_to(
  "adkeyword",
  "SearchAd::Schema::Result::Adkeyword",
  { id => "adkeyword_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-22 10:32:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rqxTY2VxrAyI/sGmfAz8Ew


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
