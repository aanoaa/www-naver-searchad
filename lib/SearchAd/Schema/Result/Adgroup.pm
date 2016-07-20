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

=head2 create_date

  data_type: 'text'
  default_value: null
  inflate_datetime: 1
  is_nullable: 1
  set_on_create: 1

=head2 update_date

  data_type: 'text'
  default_value: null
  inflate_datetime: 1
  is_nullable: 1
  set_on_create: 1
  set_on_update: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "campaign_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "target_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "str_id",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "create_date",
  {
    data_type        => "text",
    default_value    => \"null",
    inflate_datetime => 1,
    is_nullable      => 1,
    set_on_create    => 1,
  },
  "update_date",
  {
    data_type        => "text",
    default_value    => \"null",
    inflate_datetime => 1,
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

=head2 adkeywords

Type: has_many

Related object: L<SearchAd::Schema::Result::Adkeyword>

=cut

__PACKAGE__->has_many(
  "adkeywords",
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


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-07-19 18:49:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4XJa+6lyWpEik0J+lg9QeQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
