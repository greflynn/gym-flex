package Application;
use Mojo::Base 'Mojolicious';
use Application::User_Accounts;
use DateTime;

# This method will run once at server start
sub startup {
  my $self = shift;
   $self->defaults(layout => 'default');
   $self->session(logged_in => '');
   $self->session(role => '');

   $self->plugin('RemoteAddr');

   $self->secrets(['New Session {SSHA512}7HiYMvkAX9cOSjFhZKGepFKVlBdoWskRVjwHZ8G6Xj9I5JnXNytTWW3VyDr/Chjyy9izPPtmarXWff+8TMnbFuX63jk= AG Development',
      'Validation AG Development LeYTmFPhw3qZmguKrPTZhWnsLeYTmFPhw3qJmqCjyGZmguK']);

    $self->app->sessions->default_expiration('600');# Expiration reduced to 10 Minutes

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');

  my $host = 'localhost:8080';
  my $port = '3306';
  my $database = 'gym-flex';
  my $uid = 'root';
  my $pwd = 'MySqlPass!?';
  my $dsn = "DBI:mysql:database=$database;host=$host;port=$port;user=$uid;password=$pwd";

  my $application_db = Application::User_Accounts->connect($dsn);
    $self->helper(application_db => sub { return $application_db; });

    $self->helper(log_users_action => sub {
      my $self = shift;
      my $action_id = shift;
      my $additional_info = shift;

      my $users_ip = $self->remote_addr;
      my $user_id = $self->session('user_id');
      my $date_time = DateTime->now;
      my $date = $date_time->ymd;
      my $time = $date_time->hms;
        $date_time = "$date $time";


      $self->application_db->resultset('ActionLog')->create({
        action_id => $action_id,
        date_time => $date_time,
        user_id => $user_id,
        additional_info => $additional_info,
        ip_address => $users_ip
      });

      return;
    });

    $self->helper(danger_alert => sub {
      my $self = shift;
      my $message = $self->session('danger_alert') || undef;
      $self->session(danger_alert => '');

      return $message;
    });

    $self->helper(warning_alert => sub {
      my $self = shift;
      my $message = $self->session('warning_alert') || undef;
      $self->session(warning_alert => '');

      return $message;
    });

    $self->helper(success_alert => sub {
      my $self = shift;
      my $message = $self->session('success_alert') || undef;
      $self->session(success_alert => '');

      return $message;
    });

  $self->plugin('PODRenderer') if $config->{perldoc};

  my $r = $self->routes;

  $r->get('/')->name('login_form')->to(template => 'account/login_form');
  $r->post('/')->name('do_login')->to('Account#login');

  $r->route('/logout')->name('do_logout')->to(cb => sub {
   my $self = shift;

      my $user = $self->application_db->resultset('Employee')->search({uid => $self->session('user_id')});
        $user = $user->first;
        $self->log_users_action(2);

      $self->session(expires => 1);

      $self->redirect_to('login_form');
    });

  $r->get('/forgot_password')->name('forgot_password_form')->to(template => 'account/forgot_password');
  $r->post('/forgot_password')->name('send_temporary_password')->to('Account#forgot_password');

  $r->get('/account_recovery')->name('account_recovery_form')->to(template => 'account/recovery');
  $r->post('/account_recovery')->name('authenticate_account_recovery')->to('Account#recover');

  my $authorized = $r->under('/')->to('Account#is_logged_in');

  $authorized->get('/account_details')->name('account_details')->to('Account#details');
  $authorized->post('/account_details')->name('account_details_post')->to('Account#details');

  $authorized->get('/account_edit')->name('account_edit_form')->to('Account#edit_form');
  $authorized->post('/account_edit')->name('account_edit')->to('Account#edit');

  $authorized->get('/change_password')->name('change_password_form')->to('Account#change_password_form');
  $authorized->post('/change_password')->name('change_password')->to('Account#change_password');

  my $admin_authorized = $r->under('/admin')->to('Account#is_admin_logged_in');

  $admin_authorized->get('/dashboard')->name('user_dashboard')->to('User#dashboard');

  $admin_authorized ->get('/add_user')->name('user_add_form')->to('User#add_form');
  $admin_authorized->post('/add_user')->name('user_add')->to('User#add');

  $admin_authorized->get('/user_list')->name('user_index')->to('User#index');
  $admin_authorized->post('/user_list')->name('user_index')->to('User#index');

  $admin_authorized->get('/user_details')->name('user_details')->to('User#details');
  $admin_authorized->post('/user_details')->name('user_details_post')->to('User#details');

  $admin_authorized->get('/user_edit')->name('user_edit_form')->to('User#edit_form');
  $admin_authorized->post('/user_edit')->name('user_edit')->to('User#edit');

  $admin_authorized->get('/delete_user')->name('user_delete')->to('User#delete');
  $admin_authorized->post('/delete_user')->name('user_delete')->to('User#delete');

}

1;
