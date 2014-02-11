#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI::Cookie;
use DBI;

my $cgi=CGI->new();
my $dbh=DBI->connect("dbi:Pg:dbname='chadok';host=localhost", "postgres", "147570") or die "Couldn't connect";
my %cookies=CGI::Cookie->fetch;
my $session=new CGI::Session(undef, $cgi, {Diretory=>'/tmp'});
$session->expire('+1h');
my $user=undef;
if($session->param('user_name'))
{
	$user=$session->param('user_name');
}

my $redir=undef;
my $flag=0;
my $name_given=undef;
my $wrong_name_state=undef;
if($user)
{
	$redir="<meta http-equiv=\"refresh\" content=\"0; URL=http://localhost/perl/home.pl\">";	
}

else
{
    if($cgi->param('Register'))
    {
	if($cgi->param('fname') && $cgi->param('lname'))
	{
	    $fname=ucfirst(lc($cgi->param('fname')));
	    $lname=ucfirst(lc($cgi->param('lname')));
	    if($fname=~/\W/ || $lname=~/\W/)
	    {
		$wrong_name_state="Please enter valid first and last name.";
	    }
	    else
	    {
		$name_given="ok";
	    }
	}
	else
	{
		$wrong_name_state="You must enter both first and last name."
	}
	
}
