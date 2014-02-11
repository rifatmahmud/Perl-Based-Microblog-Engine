#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use DBI;

my $cgi=CGI->new();
my $dbh=DBI->connect("dbi:Pg:dbname='Upama';host=localhost", "postgres", "147570") or die "Couldn't connect";

my $numb=0;

my $cat=$cgi->param('cat');
my $name=$cgi->param('name');
my $num=$cgi->param('number');
if($cgi->param('enter'))
{
my $qur="INSERT INTO tab (name, numbers, category) VALUES('$name', to_number('$num', '99999'), '$cat')";
my $sth=$dbh->prepare($qur);
$sth->execute();
}

my $qur1="SELECT numbers FROM tab";
my $sth1=$dbh->prepare($qur1);
$sth1->execute();
while(my @dat=$sth1->fetchrow_array)
{
	$numb=$numb+$dat[0];
}
print "Content-type:text/html\n\n";

print <<END;

<html>
<head>
</head>
<body>
<form action="http://localhost/perl/input.pl" method="post">
<p>Category</p>
<input type="text" name="cat" value="Lavlu" size="100">
<p>Name</p>
<input type="text" name="name" maxlength="200">
<p>Number</p>
<input type="text" name="number" maxlength="30">
<input type="submit" name="enter" value="enter" size="40">
</form>
<p>$numb</p>
</body>
</html>
END
