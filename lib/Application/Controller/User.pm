package Application::Controller::User;

use General::Tools;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub dashboard
{
  my $self = shift;
  my @anonymous_user_actions = $self->app->application_db->resultset('ActionLog')->search({user_id => undef}, {order_by => 'id'});
   $self->stash(anonymous_user_actions => \@anonymous_user_actions);

   $self->render(template => 'user/dashboard');
}

sub index
{
  my $self = shift;
  my @users = $self->app->application_db->resultset('Employee')->search({});

  $self->stash(users => \@users);
  $self->render(template => 'user/index');
}

sub add_form
{
  my $self = shift;

  my @roles = $self->app->application_db->resultset('Role')->search({});
   $self->stash(roles => \@roles);
   $self->render(template => 'user/add');
}

sub add
{
  my $self = shift;

  my $full_name = $self->param('full_name');
  my $role = $self->param('role');
  my $random_code = generate_random_code();
  my $hashed_random_code = hash_this($random_code);
  my ($first_name, $last_name, $screen_name, $user_id, $email);


  if($full_name eq '')
  {
    $first_name = $self->param('first_name');
    $last_name = $self->param('last_name');
    $screen_name = $self->param('screen_name');
    $user_id = $self->param('user_id');
    $email = $self->param('email');
  }
  else
  {
    my $user_results = $self->user_hub->resultset('ActiveDirectory')->search({fullname => $full_name});
    my $user = $user_results->first;
    my @name_pieces = split / /, $full_name;
      $first_name = $name_pieces[0];
      $last_name = $name_pieces[1];
      $screen_name = $user->ad_accountname;
      $user_id = $user->userid;
      $email = $user->email;
  }

  my $user_results_by_screen_name = $self->app->application_db->resultset('Employee')->search({screen_name => $screen_name});
  my $user_with_screen_name = $user_results_by_screen_name->first;

  my $user_results_by_id = $self->app->application_db->resultset('Employee')->search({employee_id => $user_id});
  my $user_with_id = $user_results_by_id->first;

  my $user_results_by_email = $self->app->application_db->resultset('Employee')->search({email => $email});
  my $user_with_email = $user_results_by_email->first;

  if(defined $user_with_screen_name || defined $user_with_id)
  {
    my $danger_alert =  "A user already exists with the same screen name, user id, or email";
    $self->session(danger_alert => $danger_alert);
    $self->redirect_to('user_add_form');
  }
  else
  {
    $self->app->application_db->resultset('Employee')->create({
      first_name => $first_name,
      last_name =>  $last_name,
      screen_name => $screen_name,
      employee_id => $user_id,
      email => $email,
      role => $role,
      recovery_code => $hashed_random_code
    });

    my $subject = 'Beach App Registration';
    my $message = qq(
      Welcome to the Volusia County Beach Application $first_name.
      You have recently been registered by one of the Beach App administrators. <br>
      You may login with your email or active directory username. <br><br>
      Your temporary password is: $random_code <br>
    );

    send_alert_to($email, $subject, $message);
    my $success_alert =  "$screen_name has been added successfully.";
      $self->session(success_alert => $success_alert);

      $self->redirect_to('user_index');
  }

}

sub edit_form
{
  my $self = shift;

  my $user_id = $self->param('user_id');
  my $user_results = $self->app->application_db->resultset('Employee')->search({uid => $user_id});
  my $user = $user_results->first;
  my @roles = $self->app->application_db->resultset('Role')->search({});

   $self->stash(roles => \@roles);
   $self->stash(user => $user);
   $self->render(template => 'user/edit');
}

sub edit
{
  my $self = shift;

  my $role = $self->param('role');
  my $user_id = $self->param('user_id');
  my $user_results = $self->app->application_db->resultset('Employee')->search({uid => $user_id});
  my $user = $user_results->first;
  my $screen_name = $user->screen_name;

  $user->update({
    role => $role
  });

  my $alert = "$screen_name\'s role was successfully changed.";
   $self->session(success_alert => $alert);
  $self->redirect_to('user_index');
}

sub delete
{
  my $self = shift;

  my $user_id = $self->param('user_id');
  my $user_results = $self->app->application_db->resultset('Employee')->search({uid => $user_id});
  my $user = $user_results->first;
  my $user_screen_name = $user->screen_name;
    $user->delete;

  my $alert = "$user_screen_name was successfully deleted.";
   $self->session(success_alert => $alert);

   $self->redirect_to('user_index');
}

sub details
{
  my $self = shift;

  my $user_id = $self->param('user_id');
  my $user_results = $self->app->application_db->resultset('Employee')->search({uid => $user_id});
  my $user = $user_results->first;

  my @actions = $self->app->application_db->resultset('ActionLog')->search({user_id => $user_id}, {order_by => 'id'});

  $self->stash(users_actions => \@actions);
  $self->stash(user => $user);
  $self->render(template => 'user/details');
}

1;
