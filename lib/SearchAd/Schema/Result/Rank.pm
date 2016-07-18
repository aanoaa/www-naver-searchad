use utf8;
package SearchAd::Schema::Result::Rank;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SearchAd::Schema::Result::Rank

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<SearchAd::Schema::Base>

=cut

use base 'SearchAd::Schema::Base';

=head1 TABLE: C<rank>

=cut

__PACKAGE__->table("rank");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 adkeyword_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 rank

  data_type: 'integer'
  default_value: null
  is_nullable: 1

=head2 tobe

  data_type: 'integer'
  default_value: null
  is_nullable: 1

=head2 bid_max

  data_type: 'integer'
  default_value: null
  is_nullable: 1

=head2 bid_min

  data_type: 'integer'
  default_value: null
  is_nullable: 1

=head2 bid_interval

  data_type: 'integer'
  default_value: null
  is_nullable: 1

=head2 create_date

  data_type: 'text'
  default_value: null
  inflate_datetime: 'epoch'
  is_nullable: 1
  set_on_create: 1

=head2 update_date

  data_type: 'text'
  default_value: null
  inflate_datetime: 'epoch'
  is_nullable: 1
  set_on_create: 1
  set_on_update: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "adkeyword_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "rank",
  { data_type => "integer", default_value => \"null", is_nullable => 1 },
  "tobe",
  { data_type => "integer", default_value => \"null", is_nullable => 1 },
  "bid_max",
  { data_type => "integer", default_value => \"null", is_nullable => 1 },
  "bid_min",
  { data_type => "integer", default_value => \"null", is_nullable => 1 },
  "bid_interval",
  { data_type => "integer", default_value => \"null", is_nullable => 1 },
  "create_date",
  {
    data_type        => "text",
    default_value    => \"null",
    inflate_datetime => "epoch",
    is_nullable      => 1,
    set_on_create    => 1,
  },
  "update_date",
  {
    data_type        => "text",
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

=head2 adkeyword

Type: belongs_to

Related object: L<SearchAd::Schema::Result::Adkeyword>

=cut

__PACKAGE__->belongs_to(
  "adkeyword",
  "SearchAd::Schema::Result::Adkeyword",
  { id => "adkeyword_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-19 01:42:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dZq4zuzCSIkcPtoYNC5wAQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
