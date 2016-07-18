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
  is_auto_increment: 1
  is_nullable: 0

=head2 adgroup_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 target_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 str_id

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 bid_amt

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 on_off

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 create_date

  data_type: 'integer'
  default_value: null
  inflate_datetime: 'epoch'
  is_nullable: 1
  set_on_create: 1

=head2 update_date

  data_type: 'integer'
  default_value: null
  inflate_datetime: 'epoch'
  is_nullable: 1
  set_on_create: 1
  set_on_update: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "adgroup_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "target_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "str_id",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "bid_amt",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "on_off",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "create_date",
  {
    data_type        => "integer",
    default_value    => \"null",
    inflate_datetime => "epoch",
    is_nullable      => 1,
    set_on_create    => 1,
  },
  "update_date",
  {
    data_type        => "integer",
    default_value    => \"null",
    inflate_datetime => "epoch",
    is_nullable      => 1,
    set_on_create    => 1,
    set_on_update    => 1,
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
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 group_keywords

Type: has_many

Related object: L<SearchAd::Schema::Result::GroupKeyword>

=cut

__PACKAGE__->has_many(
  "group_keywords",
  "SearchAd::Schema::Result::GroupKeyword",
  { "foreign.adkeyword_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ranks

Type: has_many

Related object: L<SearchAd::Schema::Result::Rank>

=cut

__PACKAGE__->has_many(
  "ranks",
  "SearchAd::Schema::Result::Rank",
  { "foreign.adkeyword_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 target

Type: belongs_to

Related object: L<SearchAd::Schema::Result::Target>

=cut

__PACKAGE__->belongs_to(
  "target",
  "SearchAd::Schema::Result::Target",
  { id => "target_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 adgroups

Type: many_to_many

Composing rels: L</group_keywords> -> adgroup

=cut

__PACKAGE__->many_to_many("adgroups", "group_keywords", "adgroup");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-19 01:42:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RFdjcntSknqvlchfoLWu6A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
