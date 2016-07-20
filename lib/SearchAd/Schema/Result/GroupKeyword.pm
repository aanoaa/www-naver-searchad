use utf8;
package SearchAd::Schema::Result::GroupKeyword;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SearchAd::Schema::Result::GroupKeyword

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<SearchAd::Schema::Base>

=cut

use base 'SearchAd::Schema::Base';

=head1 TABLE: C<group_keyword>

=cut

__PACKAGE__->table("group_keyword");

=head1 ACCESSORS

=head2 adgroup_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 adkeyword_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "adgroup_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "adkeyword_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</adgroup_id>

=item * L</adkeyword_id>

=back

=cut

__PACKAGE__->set_primary_key("adgroup_id", "adkeyword_id");

=head1 RELATIONS

=head2 adgroup

Type: belongs_to

Related object: L<SearchAd::Schema::Result::Adgroup>

=cut

__PACKAGE__->belongs_to(
  "adgroup",
  "SearchAd::Schema::Result::Adgroup",
  { id => "adgroup_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 adkeyword

Type: belongs_to

Related object: L<SearchAd::Schema::Result::Adkeyword>

=cut

__PACKAGE__->belongs_to(
  "adkeyword",
  "SearchAd::Schema::Result::Adkeyword",
  { id => "adkeyword_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-07-19 05:00:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FETFlLd1J0QxdC6vZC+M/A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
