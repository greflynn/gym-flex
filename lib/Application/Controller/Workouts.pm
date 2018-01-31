package Application::Controller::Workouts;

use General::Tools;
use Mojo::Base 'Mojolicious::Controller';

sub index
{
  my $self = shift;

  return;
}

sub add_form
{
  my $self = shift;

  my $exercises = $self->app->application_db->resultset('Exercise')->search({});
  my @exercises = ();

  if($exercises)
  {
    while(my $exercise = $exercises->next)
    {
      push @exercises, {$exercise->get_columns};
    }
  }

  $self->stash(exercises => \@exercises);
  $self->render(template => 'workouts/add');
}

sub add
{
  my $self = shift;

   $self->redirect_to('workout_index');
}

1;
