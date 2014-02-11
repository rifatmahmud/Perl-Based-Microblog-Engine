#!/usr/bin/perl 

#Change the above line as needed if your perl binary file reside in different directory.

#This file's name is: index.pl

###################################################################################################################################################################
#
#This is the login page. If user name and password is found on database and match user will be redirected to his/her homepage. Otherwise he/she will be prompted to
#regiser. Any user not looged in will be redirected to this page.
#HTML and perl code has been written seperately. No framework has been used. CGI and DBI module has been used for http header and parameter handling and Database 
#handling respectively. The scripts are recommended to be run on mod_perl on GNU/Linux but are written so that they can expected to run on any webserver without 
#mod_perl on any GNU/Linux, BSD, Solaris or Unix systems without major modification. But major modification is needed if they are to be run on IIS on Windows.
#Scripts uses a PostgreSQL 8.4 database. For using other DBMS, some modifications are necessary.
#
##################################################################################################################################################################


use warnings;
use strict;
use CGI;
use DBI;
use CGI::Cookie;
use CGI::Session qw/-ip-match/;


my $cgi=CGI->new();
my $dbh=DBI->connect("dbi:Pg:dbname='chadok';host=localhost", "postgres", "147570") or die "Couldn't connect";
my %cookies=CGI::Cookie->fetch;
my $session=new CGI::Session(undef, $cgi, {Diretory=>'/tmp'});
$session->expire('+1h');
my $user_name =undef;
if($session->param('user_name'))
{
	$user_name=$session->param('user_name');
}


my $non_match=undef;
my $not_filled=undef;
my $redir="";

if($user_name && ($cgi->param('q') ne "logged_out"))
{
	$redir="<meta http-equiv=\"refresh\" content=\"0; url=http://localhost/perl/home.pl\">";
}
elsif($user_name && ($cgi->param('q') eq "logged_out"))
{
	my $unset=$cookies{"CGISESSID"}->expires('-3M');
	$cookies{"CGISESSID"}->bake;
	$session->delete();
}
else
{
    	if ($cgi->param('Login'))
    	{
		if ($cgi->param('user') && $cgi->param('pword'))
		{
	    		my $user=$cgi->param('user');
	    		my $pword=$cgi->param('pword');
	    		my $qur="SELECT user_id, pword FROM user_list WHERE user_id='$user' AND pword=md5('$pword')";
	    		my $sth=$dbh->prepare($qur);
	    		$sth->execute();
	    		if($sth->fetchrow_array())
	    		{
	    			$session->param('user_name', $user);
				my $user_cookie=CGI::Cookie->new(-name=>"CGISESSID", -value=>$session->id);
				$user_cookie->bake;
				$redir="<meta http-equiv=\"refresh\" content=\"0; url=http://localhost/perl/home.pl\">";
	    		}
	    		else
	    		{
	    			$non_match="User name and Password do not match.";
	    		}
		}
		else
		{
			$not_filled="You must enter user name and password.";
		}
	}
}


print "Content-type: text/html\n\n";

print <<ENDHTML;



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<title></title>
<meta name="author" content="Rifat Mahmud">
<meta name="date" content="2011-07-08T21:30:22+0600">
<meta name="copyright" content="Rifat Mahmud">
<meta name="keywords" content="Social Networking, Social Media">
<meta name="description" content="This is the login page for Chadok">
$redir
<style type="text/css">
body {
	background-color: #0C741D;
}
h1 {
	text-align: center;
	color: red;
	font-size: normal;
	font-stretch: wider;
	font-family: arial, helvetica, sans-serif;
}
form {
	text-align: center;
	vertical-align: middle;
}
button {
	font: black;
	color: #53966F;
}
</style>
</head>
<body>
<h1>SIMPLOG</h1>
<form method="POST" action="http://localhost/perl/index.pl">

<p>User Name</p><input type="text" name="user" value="" />
<p>Password</p><input type="password" name="pword" value="" />
<br/><input type="submit" name="Login" value="Login" size="10">
</form>
<p style="text-align:center">$non_match<p>
 <p style="text-align:center">$not_filled<p>
<p style="font-size:small-caps; text-align:center">Don't have an account?<a href="http://localhost/perl/register.pl">Register</a></p>

ENDHTML
