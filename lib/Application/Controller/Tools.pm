package Tools;
#use strict;

use MIME::Lite;
use warnings;
use XML::DOM;
use Data::Dumper;
use Peterka::mark;
use IO::Socket;  #for writedb and ip address
use File::Spec::Functions qw(splitpath);
use IO::File;
use IO::Uncompress::Unzip qw($UnzipError);
use File::Path qw(mkpath);
use DateTime;

require Exporter;
our @ISA = ("Exporter");
our @EXPORT = qw(check_password_is_temporary validate_password home_page_for log_failed_login_for log_failed_recovery_for );

sub check_password_is_temporary
{
  my $password = shift;
  my $password_length = length $password;
  my $result;

  if(($password_length == 25) && ($password =~ m/[a-zA-Z]/))
  {
    $result = 1;
  }

  return $result;
}

sub validate_password
{
  my ($password, $correct_password) = @_;
  my $result = $password eq $correct_password ? 1 : undef;

  return $result;
}

sub home_page_for
{
  my $user = shift;
  my $home_page = $user->role eq 'RID00000002' ? 'user_dashboard' : 'form_index';

  return $home_page;
}

sub log_failed_login_for
{
  my $user = shift;
  my $number_of_failed_logins = $user->failed_logins;
      $number_of_failed_logins++;

      $user->update({
        failed_logins => $number_of_failed_logins
      });

  return;
}

sub log_failed_recovery_for
{
  my $user = shift;

  my $number_of_failed_receoveries = $user->failed_recoveries;
    $number_of_failed_receoveries++;

    $user->update({
      failed_recoveries => $number_of_failed_receoveries
    });

  return;
}

1;
