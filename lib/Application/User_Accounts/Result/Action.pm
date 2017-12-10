use utf8;
package Application::User_Accounts::Result::Action;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("Actions");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-07-17 12:53:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JNvJNCmNlBOLx5VwwoH6HQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
