use utf8;
package SearchAd::Schema::Result::Target;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SearchAd::Schema::Result::Target

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<SearchAd::Schema::Base>

=cut

use base 'SearchAd::Schema::Base';

=head1 TABLE: C<target>

=cut

__PACKAGE__->table("target");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 url

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
  "url",
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

=head2 adkeywords

Type: has_many

Related object: L<SearchAd::Schema::Result::Adkeyword>

=cut

__PACKAGE__->has_many(
  "adkeywords",
  "SearchAd::Schema::Result::Adkeyword",
  { "foreign.target_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-19 01:42:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I4zZYPIBthg9tyw2hJIlgw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
