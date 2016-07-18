use utf8;
package SearchAd::Schema::Result::Adgroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SearchAd::Schema::Result::Adgroup

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<SearchAd::Schema::Base>

=cut

use base 'SearchAd::Schema::Base';

=head1 TABLE: C<adgroup>

=cut

__PACKAGE__->table("adgroup");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 campaign_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 str_id

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

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
  "campaign_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "str_id",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
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

=head2 adkeywordss

Type: has_many

Related object: L<SearchAd::Schema::Result::Adkeyword>

=cut

__PACKAGE__->has_many(
  "adkeywordss",
  "SearchAd::Schema::Result::Adkeyword",
  { "foreign.adgroup_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 campaign

Type: belongs_to

Related object: L<SearchAd::Schema::Result::Campaign>

=cut

__PACKAGE__->belongs_to(
  "campaign",
  "SearchAd::Schema::Result::Campaign",
  { id => "campaign_id" },
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
  { "foreign.adgroup_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 adkeywords

Type: many_to_many

Composing rels: L</group_keywords> -> adkeyword

=cut

__PACKAGE__->many_to_many("adkeywords", "group_keywords", "adkeyword");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-19 01:46:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1rAPXiXWWVDsYN4lV1KnlQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
