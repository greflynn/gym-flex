package Application::Controller::Exercise;

use Mojo::Base 'Mojolicious::Controller';
use File::Basename;
use lib dirname(__FILE__);


sub index
{
  my $self = shift;

  my @exercises = $self->app->application_db->resultset('Exercise')->search({});

  $self->stash(exercises => \@exercises);
  $self->render(template => 'exercise/index');
}

sub add
{
  my $self = shift;

  my $exercise = $self->param('exercise');
  my $description = $self->param('description');
  my $muscle_group = $self->param('muscle_group');

  $self->app->application_db->resultset('Exercise')->create({
    exercise => $exercise,
    description => $description,
    muscle_group => $muscle_group,
    user_id => $self->session('user_id')
  });

  $self->redirect_to('workout_index');
}

1;
