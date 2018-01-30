package Application::Controller::Account;
BEGIN
{
  unshift @INC, '\\\\erp311script\Library\StrawberryPerl';
}
use Mojo::Base 'Mojolicious::Controller';
use General::Tools;
use File::Basename;
use lib dirname(__FILE__);
use Tools;

sub user_exists
{
    my ($user_name, $password, $self) = @_;

    if(defined $password && $password ne '')
    {
      my $user_result_set = $self->app->application_db->resultset('Employee');
      my $search_results;

      if($user_name =~ m/\@/)
      {
        my $email = $user_name;
         $search_results =  $user_result_set->search({email => $email, password => $password});
      }
      else
      {
        $search_results =  $user_result_set->search({screen_name => $user_name, password => $password});
      }

      my $existing_user = defined $search_results ? $search_results->first : undef($search_results);

      return ($existing_user);
    }
    else
    {
      $self->redirect_to('account_recovery_form');
    }
}

sub login
{
  my $self = shift;

  my $user_name = $self->param('user_name');
  my $password = $self->param('password');
  my $user_results;
  if($user_name =~ m /\@/)
  {
    my $email = $user_name;
    $user_results = $self->app->application_db->resultset('Employee')->search({email => $email});
  }
  else
  {
    $user_results = $self->app->application_db->resultset('Employee')->search({screen_name => $user_name});
  }
  my $existing_user = $user_results->first;

  if($existing_user)
  {
    my $user_password = defined $existing_user->password ? $existing_user->password : $existing_user->recovery_code;

    my $password_is_correct = validate_hash($user_password, $password);

    if($password_is_correct)
    {
      $self->session(logged_in => 1);
      $self->session(user_id => $existing_user->uid);
      $self->session(role => $existing_user->role);

      $self->log_users_action(1, "Success");

       $self->redirect_to('workout_dashboard');
    }
    else
    {
        $self->log_users_action(1, "Failed: Wrong Password");
        log_failed_login_for($existing_user);
        my $alert = 'The username or password entered was incorrect';
         $self->session(danger_alert => $alert);

         $self->render(template => 'account/login_form');
    }
  }
  else
  {
    $self->log_users_action(1, "Failed: No Such User");

    my $alert = 'The username or password entered was incorrect';
     $self->session(danger_alert => $alert);

     $self->render(template => 'account/login_form');
  }
}

sub is_logged_in
{
  my $self = shift;

  return 1 if $self->session('logged_in');

  $self->redirect_to('login_form');
}

sub is_admin_logged_in
{
  my $self = shift;

  if ($self->session('logged_in') eq '1' && $self->session('role') eq 'RID00000002')
  {
    return 1;
  }

  $self->redirect_to('login_form');
}

sub details
{
    my $self = shift;
    my $user_id = $self->session('user_id');
    my $user_results = $self->app->application_db->resultset('Employee')->search({uid => $user_id});
    my $user = $user_results->first;

     $self->stash(user => $user);
     $self->render(template => 'account/details');
}

sub edit_form
{
  my $self = shift;

  my $user_id = $self->param('user_id');
  my $user_results = $self->app->application_db->resultset('Employee')->search({uid => $user_id});
  my $user = $user_results->first;

   $self->stash(user => $user);
   $self->render(template => 'account/edit');
}

sub edit
{
  my $self = shift;

  my $first_name = $self->param('first_name');
  my $last_name = $self->param('last_name');
  my $email = $self->param('email');
  my $screen_name = $self->param('screen_name');
  my $user_id = $self->param('user_id');
  my $user_results = $self->app->application_db->resultset('Employee')->search({uid => $user_id});
  my $user = $user_results->first;

  my $additional_info = '';
   $additional_info .= $user->first_name eq $first_name ? '' : 'First Name:'.$user->first_name." -> $first_name";
   $additional_info .= $user->last_name eq $last_name ? '' : 'Last Name:'.$user->last_name." -> $last_name";
   $additional_info .= $user->email eq $email ? '' : 'Email: '.$user->email." -> $email";
   $additional_info .= $user->screen_name eq $screen_name ? '' : 'Screen Name: '.$user->screen_name." -> $screen_name";

  $user->update({
    first_name => $first_name,
    last_name => $last_name,
    email => $email,
    screen_name => $screen_name
  });

   $self->log_users_action( 3, $additional_info);

  my $alert = "Your account information was changed successfully";
   $self->session(success_alert => $alert);

   $self->redirect_to('account_details');
}

sub change_password_form
{
  my $self = shift;

  my $user_id = $self->session('user_id');
  my $user_results = $self->app->application_db->resultset('Employee')->search({uid => $user_id});
  my $user = $user_results->first;
    $self->stash(user => $user);
    $self->render(template => 'account/change_password');
}

sub change_password
{
  my $self = shift;

  my $user_id = $self->session('user_id');
  my $user_results = $self->app->application_db->resultset('Employee')->search({uid => $user_id});
  my $user = $user_results->first;

  my $users_password = defined $user->password ? $user->password : $user->recovery_code;
  my $old_password = $self->param('old_password');

  my $new_password = $self->param('new_password');
  my $verified_password = $self->param('verify_password');

  my $password_is_correct = validate_hash($users_password, $old_password);
  if($password_is_correct == 1 && ($new_password eq $verified_password))
  {
    $new_password = hash_this($new_password);
    $user->update({
      password => $new_password
    });
    my $alert = "You just changed your password, please login";
     $self->session(success_alert => $alert);

     $self->log_users_action(4);

     $self->redirect_to('do_logout');
  }
  else
  {
    my $alert = "Your passwords did not match or you did not enter your current password correctly, please try again.";
     $self->session(danger_alert => $alert);

     $self->log_users_action(4, "Failed");

     $self->redirect_to('change_password_form');
  }
}

sub forgot_password
{
  my $self = shift;

  my $email = $self->param('email');
  my $user_results = $self->app->application_db->resultset('Employee')->search({email => $email});
  my $user = $user_results->first;

  if($user)
  {
    $self->session(logged_in => 0);
    my $temporary_code = generate_random_code();
    my $hashed_temporary_code = hash_this($temporary_code);
    $user->update({
      password => '',
      recovery_code => $hashed_temporary_code
    });

    my $subject = 'Beach Safety App: Account Helper';
    my $message = qq(
      You have requested assistance in regaining access to your account. <br>
      Please follow the link below, using your temporary code. Also have your user ID ready.<br><br>

      Temporary Code: $temporary_code
    );

    send_alert_to($email, $subject, $message) or $self->redirect_to('forgot_password_form');

    $self->log_users_action(5);

     $self->redirect_to('account_recovery_form');
  }
  else
  {
    $self->log_users_action(5, "Failed: Incorrect user ID");
    $self->redirect_to('forgot_password_form');
  }
}

sub recover
{
  my $self = shift;

  my $temporary_code = $self->param('temporary_code');
    $temporary_code = trim($temporary_code);
  my $user_id = $self->param('user_id');

  my $user_results = $self->app->application_db->resultset('Employee')->search({employee_id => $user_id});
  my $user = $user_results->first;

  if($user)
  {
    my $user_recovery_code = $user->recovery_code;
    my $temporary_code_is_valid = validate_hash($user_recovery_code, $temporary_code);

    if($temporary_code_is_valid)
    {
      my $new_password = $self->param('new_password');
      my $verify_password = $self->param('verify_password');

      if($new_password eq $verify_password)
      {
        $new_password = hash_this($new_password);
        $user->update({
          recovery_code => '',
          password => $new_password
        });
        $self->log_users_action(6, "Success");
        $self->redirect_to('do_logout');
      }
      else
      {
        my $alert = "Your passwords did not match, please try again.";
         $self->session(danger_alert => $alert);

         $self->log_users_action(5, 'Failed: Mismatch Passwords');
         $self->redirect_to('account_recovery_form');
      }
    }
    else
    {
      $self->log_users_action(6, "Failed: Incorrect Recovery Code"
      );
      my $alert = "Your recovery code was incorrect, please try again.";
        $self->session(danger_alert => $alert);

        $self->redirect_to('account_recovery_form');
    }
  }
  else
  {
    my $alert = "Something went wrong with recovering your account, please try again.";
        $self->session(danger_alert => $alert);

        $self->log_users_action(6, 'Failed: Incorrect user ID');

        $self->redirect_to('account_recovery_form');
  }
}

1;
