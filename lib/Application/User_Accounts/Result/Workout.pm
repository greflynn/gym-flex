use utf8;
package Application::User_Accounts::Result::Workout;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("Workouts");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "set_number",
  { data_type => "integer", is_nullable => 1 },
  "reps",
  { data_type => "integer", is_nullable => 1 },
  "weight",
  { data_type => "integer", is_nullable => 1 },
  "exercies",
  { data_type => "nchar", is_nullable => 1, size => 10 },
  "workout_id",
  { data_type => "integer", is_nullable => 1 },
  "user_id",
  { data_type => "varchar", is_nullable => 1, size => 11 },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-01-31 12:54:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sitIY2i/e9DJlmXi0Vs4Wg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
