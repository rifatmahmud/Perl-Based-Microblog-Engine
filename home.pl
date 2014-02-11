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
if($session->param('user_name'))
{
	$user=$session->param('user_name');
}


my $redir="<meta http-equiv=\"refresh\" content=\"60; URL=http:\/\/localhost\/perl/home.pl\">";

if($user)
{
	if($cgi->param('post'))
	{
		if(length($cgi->param('stat'))>140)
		{
		
			$exceeded="<p>Character limit exceeded</p>";
			$cgi->delete('stat');
		}
		else
		{
			my $stat=$cgi->param('stat');
			my $tags=" ";
			my $user_tags=" ";
			$_=$stat;
			my $temp2=".";
			while($_=~/(&lt\b)|(&gt\b)|(&amp\b)|(<)|(>)/)
			{
				if(($& eq '&lt')||($& eq '&LT')||($& eq '&Lt')||($& eq '&lT'))
				{
					$temp2=$temp2 . $` . "&amp;" . substr($&, 1);
					$_=$';
				}
				elsif(($& eq '&gt')||($& eq '&GT')||($& eq '&Gt')||($& eq '&gT'))
				{
					$temp2=$temp2 . $` . "&amp;" . substr($&, 1);
					$_=$';
				}
				elsif(lc($&) eq lc('&amp'))
				{
					$temp2=$temp2 . $` . "&amp;" . substr($&, 1);
					$_=$';
				}
				elsif($& eq '<')
				{
					$temp2=$temp2 . $` . "&lt;";
					$_=$';
				}
				elsif($& eq '>')
				{
					$temp2=$temp2 . $` . "&gt;";
					$_=$';
				}
			}
			$temp2=$temp2 . $_;
			$stat=substr($temp2, 1);
			$_=$stat;
			while($_ =~ s/@[\w_]+\b//)
			{
				my $temp=$&;
				my $user_test=substr($temp, 1);
				my $qur_u="SELECT user_id FROM user_list WHERE user_id='$user_test'";
				my $sth_u=$dbh-prepare($qur_u);
				$sth_u->execute();
				if($sth_u->rows)
				{
					$user_tags=$user_tags . $user_test . " ";
					$stat =~ s/\Q$temp\E/<a href="http:\/\/localhost\/perl\/profile.pl?id=$temp">$temp<\/a>/;
				}
			}
			while($_=~ s/%[\S]+//)
			{
				my $temp=$&;
				$tags=$tags . $temp . " ";
				$stat =~ s/\Q$temp\E/<a href="http:\/\/localhost\/perl\/search.pl?id=$temp">$temp<\/a>/;
			}
			while($_=~ s/(http|https|ftp|news|file):\/\/[\S]*//)
			{
				my $temp=$&;
				$stat =~ s/\Q$temp\E/<a href="$temp">$temp<\/a>/;
			}
			$_=$stat;
			$_=~s/&lt;(?=[\S]*">)/</g;
			$_=~s/&gt;(?=[\S]*>")/>/g;
			$_=~s/&amp;(?=(lt|gt|amp)[\S]*">)/&/g;
			$stat=~s/\\/\\\\/g;
			$stat=~s/\'/\\\'/g;
			if($stat=~/^pm:/i)
			{
				my $qur="INSERT INTO post_tab (post_text, posted_by, posted_in, post_id, tags, user_to, msg) VALUES(\'$stat\', \'$user\', now(), \'$user\' || to_char(now(), \'HH24:MI:SS DD-MM-YYYY\'), \'$tags\', \'$user_tags\', \'yes\')";
				my $sth=$dbh->prepare($qur);
				$sth->execute();
			}
			else
			{
				my $qur="INSERT INTO post_tab (post_text, posted_by, posted_in, post_id, tags, user_to) VALUES(\'$stat\', \'$user\', now(), \'$user\' || to_char(now(), \'HH24:MI:SS DD-MM-YYYY\'), \'$tags\', \'$user_tags\')";
				my $sth=$dbh->prepare($qur);
				$sth->execute();
			}
		}
	}
	else
	{
		my $redir="<meta http-equiv=\"refresh\" content=\"0; URL=http:\/\/localhost\/perl/home.pl\">";
	}
}
else
{
	$redir="<meta http-equiv=\"refresh\" content=\"0; URL=http:\/\/localhost\/perl/index.pl\">";
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
<h1>HOME</h1>
<form method="post">
<textarea name="stat" rows="10" cols="50"></textarea>
<input type="submit" name="post" value="post">
</form>
$exceeded
ENDHTML1
	my $qur="SELECT post_text, posted_in, posted_by FROM post_tab WHERE posted_by=" . "'$user'" . " OR posted_by=ANY(SELECT id FROM " . $user . "_following) ORDER BY posted_in desc";
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


