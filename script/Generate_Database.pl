#!C:\Strawberry\perl\bin\perl.exe

use File::Basename;
BEGIN{unshift @INC, dirname(__FILE__)."\\..\\lib";}

use Application::User_Accounts;


=pod
You have to create the database and set up a user, then run this script against it to generate all the tables

Add any data that you want prepopulated here, to help speed things up (User, Roles, etc.)
=cut

my $host = 'localhost:8080';
my $port = '3306';
my $database = 'gym-flex';
my $uid = 'root';
my $pwd = 'MySqlPass!?';
my $dsn = "DBI:mysql:database=$database;host=$host;port=$port;user=$uid;password=$pwd";
#my $schema = Application::User_Accounts->connect($dsn);
my $schema = Application::User_Accounts->connect('DBI:ODBC:DRIVER={SQL Server};SERVER=ENNTEST;DATABASE=test;, test, test');
 $schema->deploy();

my @in_all_actions = ("Log In", "Log Out", "Edit Account Info", "Change Password", "Request Temporary Password", "Recover Account", "Visit Page");

foreach my $action (@in_all_actions)
{
  $schema->resultset('Action')->create({
    name => $action
  });
}

my @in_all_roles = ("member", "admin", "super admin");
foreach my $role (@in_all_roles)
{
  $schema->resultset('Role')->create({
    title => $role
  });
}
