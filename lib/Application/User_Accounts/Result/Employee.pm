use utf8;
package Application::User_Accounts::Result::Employee;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("Employee");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uid",
  { data_type => "varchar", is_nullable => 0, size => 11 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "screen_name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 150 },
  "recovery_code",
  { data_type => "varchar", is_nullable => 1, size => 150 },
  "role",
  { data_type => "nchar", is_nullable => 1, size => 11 },
  "failed_logins",
  { data_type => "integer", is_nullable => 1 },
  "failed_recoveries",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-01-31 12:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6xN4wodDcIxMuNDZ9MsOfw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
