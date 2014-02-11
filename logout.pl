#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI::Cookie;
use CGI::Session qw /-ip-match/;
use DBI;

my $cgi=CGI->new();
my %cookies=CGI::Cookie->fetch;
my $session=new CGI::Session(undef, $cgi, {Diretory=>'/tmp'});
my $user=undef;
if($session->param('user_name'))
{
	$user=$session->param('user_name');
}

if($user)
{
	$cgi->redirect("http://localhost/perl/index.pl?q=logged_out");
}
else
{
	$cgi->redirect("http://localhost/perl/index.pl");
}


