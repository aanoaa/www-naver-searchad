use utf8;
package SearchAd::Schema::Result::Adkeyword;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SearchAd::Schema::Result::Adkeyword

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<SearchAd::Schema::Base>

=cut

use base 'SearchAd::Schema::Base';

=head1 TABLE: C<adkeyword>

=cut

__PACKAGE__->table("adkeyword");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 adgroup_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 rank_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 str_id

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 max_depth

  data_type: 'integer'
  is_nullable: 0

=head2 create_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  inflate_datetime: 1
  is_nullable: 1
  set_on_create: 1

=head2 update_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  inflate_datetime: 1
  is_nullable: 1
  set_on_create: 1
  set_on_update: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "adgroup_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "rank_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "str_id",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "max_depth",
  { data_type => "integer", is_nullable => 0 },
  "create_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    inflate_datetime => 1,
    is_nullable => 1,
    set_on_create => 1,
  },
  "update_date",
  {
    data_type                 => "datetime",
    datetime_undef_if_invalid => 1,
    inflate_datetime          => 1,
    is_nullable               => 1,
    set_on_create             => 1,
    set_on_update             => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 adgroup

Type: belongs_to

Related object: L<SearchAd::Schema::Result::Adgroup>

=cut

__PACKAGE__->belongs_to(
  "adgroup",
  "SearchAd::Schema::Result::Adgroup",
  { id => "adgroup_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 rank

Type: belongs_to

Related object: L<SearchAd::Schema::Result::Rank>

=cut

__PACKAGE__->belongs_to(
  "rank",
  "SearchAd::Schema::Result::Rank",
  { id => "rank_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-22 09:40:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z137scYcWJzYqZuH54zz5g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
