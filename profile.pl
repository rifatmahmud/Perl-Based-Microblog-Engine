#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI::Cookie;
use CGI::Session qw/-ip-match/;
use DBI;

my $cgi=CGI->new();
my $dbh=DBI->connect("dbi:Pg:dbname='chadok';host=localhost", "postgres", "111111") or die "Couldn't connect";
my %cookies=CGI::Cookie->fetch;
my $session=new CGI::Session(undef, $cgi, {Diretory=>'/tmp'});
$session->expire('+1h');
my $user_name =undef;
my $follow_flag=undef;
my $unfollow_flag=undef;
my $nonuser_flag=undef;
my $prof_owner_flag=undef;
my $pending_flag=undef;
my $redir=undef;
my $private_flag=undef;
if($session->param('user_name'))
{
	$user_name=$session->param('user_name');
} 

if($user_name)
{
	if($cgi->param('id') ne $user_name)
	{
		my $prof_holder=$cgi->param('id');
		my $qur2="SELECT privacy FROM user_list WHERE user_id='$prof_holder'";
		my $sth2=$dbh->prepare($qur2);
		$sth2->execute();
		if($sth2->rows)
		{
			my $qur3="SELECT * FROM $prof_holder" . "_block_list WHERE id='$user_name'";
			my $sth3=$dbh->prepare($qur3);
			$sth3->execute();
			if(!$sth3->rows)
			{
				my $qur4="SELECT status FROM $prof_holder" . "_followers WHERE id='$user_name'";
				my $sth4=$dbh->prepare($qur4);
				$sth4->execute();
				my @priv=$sth2->fetchrow_array;
				my @pend=$sth4->fetchrow_array;
				if(($priv[0] eq "on")&&(!$sth4->rows))
				{
					$follow_flag="on";
					$private_flag="on";
				}
				elsif(($priv[0] eq "off")&&(!$sth4->rows))
				{
					$follow_flag="on";
				}
				elsif(($sth4->rows)&&($pend[0] eq "p"))
				{
					$pending_flag="on";
				}
				else
				{
					$unfollow_flag="on";
				}
			}
			else
			{
				$redir="<meta http-equiv=\"refresh\" content=\"0; URL=http://localhost/perl/home.pl\">";
			}
		}
		else
		{
			$redir="<meta http-equiv=\"refresh\" content=\"0; URL=http://localhost/perl/home.pl\">";
		}
	}
	else
	{
		$prof_owner_flag="on";
	}
}
else
{
	$redir="<meta http-equiv=\"refresh\" content=\"0; URL=http://localhost/perl/index.pl\">";
}
print "Content-type: text/html\n\n";

print <<ENDHTML1;
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
$redir
<style>
body {
	background-color: #C36A12;
}
form {
	text-align: center;
}
h1 {
	font-size: 20pt;
	color: #FFFFFF;
	text-align: right;
}
</style>
</head>
<body>
<h1>$cgi->param('id')</h1>

ENDHTML1
	my $prof_holder=$cgi->param('id');
	my $qur="SELECT post_text, posted_in, posted_by FROM post_tab WHERE posted_by='" . $prof_holder . "' ORDER BY posted_in";
	my $sth=$dbh->prepare($qur);
	$sth->execute();
	while(my @dat=$sth->fetchrow_array)
	{
		print "<p  style=\"text-align: center; color: blue; background-color: #FFFFFF;\">$dat[2]</p>";
		print "<p  style=\"text-align: center; color: black; background-color: #FFFFFF;\">$dat[0]</p>";
	}
print <<ENDHTML2;
</body>
</html>
ENDHTML2

