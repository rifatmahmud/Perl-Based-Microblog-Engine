#!/usr/bin/perl

use warnings;
use strict;
use CGI;
use DBI;
use Email::Valid;

my $cgi=CGI->new();
my $dbh=DBI->connect("dbi:Pg:dbname='chadok';host=localhost", "postgres", "147570") or die "Couldn't connect";

my $user_name=$cgi->cookie("user_name");

sub generate_form{
    print $cgi->start_form();
    print $cgi->p("First Name:"); 
    print $cgi->textfield('fname');
    print "</br>";
    print $cgi->p("Last Name:"); 
    print $cgi->textfield('lname');
    print "</br>";
    print $cgi->p("Enter a Valid Email Address:");
    print $cgi->textfield('email');
    print "</br>";
    print $cgi->p("Enter a user name\n(Should only contain alphanumeric characters, '.' and '_')");
    print $cgi->textfield('user_id');
    print "</br>";
    print $cgi->p("Enter New Password\n(Should only contain alphanumeric characters)");
    print $cgi->password_field('pword');
    print "</br>";
    print $cgi->p("Retype Password:");
    print $cgi->password_field('pword2');
    print "</br>";
    print $cgi->p("Write something about yourself(In less than 300 words:");
    print $cgi->textarea('about', 10, 50);
    print "</br>";
    print $cgi->submit('Register');
    print $cgi->end_form();
}

my $flag=0;
my $fname=undef;
my $lname=undef;
my $user_id=undef;
my $email=undef;
my $pword=undef;
my $pword2=undef;
my $about=undef;

if($user_name)
{
    $cgi->redirect("http://localhost/perl/home.pl");
}
else
{
    print $cgi->header();
    print $cgi->start_html("Sign Up");
    generate_form();
    if($cgi->param('Register'))
    {
	if($cgi->param('fname') && $cgi->param('lname'))
	{
	    $fname=ucfirst(lc($cgi->param('fname')));
	    $lname=ucfirst(lc($cgi->param('lname')));
	    if($fname=~/\W/ || $lname=~/\W/)
	    {
		print $cgi->p("please enter a valid name");
	    }
	    else
	    {
		$flag++;
	    }
	}
	else
	{
	    print $cgi->p("Please enter both first name and last name.");
	}
	if($cgi->param('email'))
	{
	    $email=$cgi->param('email');
	    my $qur_e="SELECT * FROM user_list WHERE email_add=" . "'$email'";
	    my $sth_e=$dbh->prepare($qur_e);
	    $sth_e->execute();
	    if(Email::Valid->address(-address=>$email) && !$sth_e->fetchrow_array())
	    {
		$flag++;
	    }
	    elsif(!(Email::Valid->address(-address=>$email)) && !$sth_e->fetchrow_array())
	    {
		print $cgi->p("Email address not valid.");
	    }
	    else
	    {
		print $cgi->p("Email address already used.");
	    }
	}
	else
	{
	    print $cgi->p("Please, enter a valid email address.");
	}
	if($cgi->param('user_id'))
	{
	    $user_id=lc($cgi->param('user_id'));
	    my $qur_u="SELECT * FROM user_list WHERE user_id=" . "'$user_id'";
	    my $sth_u=$dbh->prepare($qur_u);
	    $sth_u->execute();
	    if($user_id=~/[^a-z,0-9, ., _]/ && !$sth_u->fetchrow_array())
	    {
		print $cgi->p("User name contain illegal characters.");
	    }
	    elsif($user_id!~/[^a-z,0-9, ., _]/ && $sth_u->fetchrow_array())
	    {
		print $cgi->p("User name already used.");
	    }
	    else
	    {
		  $flag++;
	    }
	}
	else
	{
	    print $cgi->p("Please enter a user name.");
	}
	if($cgi->param('pword') && $cgi->param('pword2'))
	{
	    $pword=$cgi->param('pword');
	    $pword2=$cgi->param('pword2');
	    if($pword ne $pword2)
	    {
		print $cgi->p("Passwords do not match");
	    }
	    elsif(($pword eq $pword2) && ($pword=~/\W/))
	    {
		print $cgi->p("Password contains illegal characters.");
	    }
	    else
	    {
		$flag++;
	    }
	}
	else
	{
	    print $cgi->p("Provide and confirm the password.");
	}
	$about=$cgi->param('about');
	if($flag==4)
	{
	    my $qur="INSERT INTO user_list (first_name, last_name, email_add, user_id, pword, about) VALUES(" . "'$fname'" . "," . "'$lname'" . "," . "'$email'" . "," . "'$user_id'" . "," . "md5('$pword')" . "," . "'$about'" . ")";
	    my $sth=$dbh->prepare($qur);
	    $sth->execute();
	    my $qur2="CREATE TABLE " . $user_id . "_followers (id varchar(100), group_name varchar(10), status varchar(3))";
	    my $qur3="CREATE TABLE " . $user_id . "_following (id varchar(100), group_name varchar(10), status varchar(3))";
	    my $qur4="CREATE TABLE " . $user_id . "_block_list (id varchar(100))";
   	    my $qur5="CREATE TABLE " . $user_id . "_blocked_by (id varchar(100))";
	    my $sth2=$dbh->prepare($qur2);	
	    $sth2->execute();
	    my $sth3=$dbh->prepare($qur3);
	    $sth3->execute();
	    my $sth4=$dbh->prepare($qur4);
	    $sth4->execute();
	    my $sth5=$dbh->prepare($qur5);
	    $sth5->execute();
	    $cgi->redirect("http://localhost/perl/home.pl");
	}
    }
}

print $cgi->end_html();
