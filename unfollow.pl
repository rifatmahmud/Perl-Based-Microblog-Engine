#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI::Cookie;
use CGI::Session qw /-ip-match/;
use DBI;

my $cgi=CGI->new();
my $dbh=DBI->connect("dbi:Pg:dbname=chadok; host=localhost", "postgres", "147570");
my %cookies=CGI::Cookie->fetch;
my $session=new CGI::Session(undef, $cgi, {Diretory=>'/tmp'});
$session->expire('+1h');
my $exceeded=undef;
my $user=undef;
my $priv_flag=undef;

if($session->param('user_name'))
{
	$user=$session->param('user_name');
}

my $unfollow_user=$cgi->param('id');

my $qur="SELECT * FROM $user" . "_following WHERE id='$unfollow_user'";
my $sth=$dbh->prepare($qur);
$sth->execute();
if($sth->rows)
{
	my $qur1="DELETE FROM $user" . "_following WHERE id='$unfollow_user'";
	my $sth1=$dbh->prepare($qur1);
	$sth1->execute();
}

print "Content-type:text/html\n\n";

print <<ENDHTML;

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title></title>

<meta name="author" content="root">
<meta name="date" content="2011-07-10T03:46:06+0600">
<meta name="copyright" content="">
<meta name="keywords" content="">
<meta name="description" content="">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<meta http-equiv="content-type" content="application/xhtml+xml; charset=UTF-8">
<meta http-equiv="content-style-type" content="text/css">
<meta http-equiv="refresh" content="0; URL=http://localhost/perl/profile.pl?id=$unfollow_user">
</head>
<body>
</body>
</html>
ENDHTML
