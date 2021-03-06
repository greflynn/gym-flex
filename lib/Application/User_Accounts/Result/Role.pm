use utf8;
package Application::User_Accounts::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("Role");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "role_id",
  { data_type => "varchar", is_nullable => 1, size => 11 },
  "title",
  { data_type => "nchar", is_nullable => 1, size => 25 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-01-31 12:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:H/7N1GoYG9dap6ByuNn+Cw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
