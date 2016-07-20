use utf8;
package SearchAd::Schema::Result::Profile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SearchAd::Schema::Result::Profile

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<SearchAd::Schema::Base>

=cut

use base 'SearchAd::Schema::Base';

=head1 TABLE: C<profile>

=cut

__PACKAGE__->table("profile");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 customer_id

  data_type: 'text'
  default_value: null
  is_nullable: 1

=head2 api_key

  data_type: 'text'
  default_value: null
  is_nullable: 1

=head2 api_secret

  data_type: 'text'
  default_value: null
  is_nullable: 1

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
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "customer_id",
  { data_type => "text", default_value => \"null", is_nullable => 1 },
  "api_key",
  { data_type => "text", default_value => \"null", is_nullable => 1 },
  "api_secret",
  { data_type => "text", default_value => \"null", is_nullable => 1 },
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

=head2 user

Type: belongs_to

Related object: L<SearchAd::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "SearchAd::Schema::Result::User",
  { id => "user_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-19 05:30:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dxZY+9T5II/BD32ZeFGW+w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
