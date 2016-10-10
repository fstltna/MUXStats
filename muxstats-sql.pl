#!/usr/bin/perl

# Creates stats from the active Lugdunon server
#
# Settings:
$OUTDIR="/var/www/html/muxstats";
$WEBDIR="/muxstats/";
$LOGO="logoSmall.png";
$SERVER_NAME="MekCity";
$REVVER="1.0";
$SERVERHOST="mekcity.com";
$SERVERPORT="3067";

my $DESIRED_NAME = "MarisaG";
my $UserID;
my $RealName;
my $convertedname;
my $Player_Name;

sub ConvertName ()
{
	my $OutputName;

	$OutputName = lc($RealName);
	$OutputName =~s/ /-/g;
	return($OutputName);
}

# Load our dependancies
#use strict;
use File::Copy qw(copy);
#use Net::Telnet();
use DBI;

my ($t, @output);

# Code below here
if (-e $OUTDIR and -d $OUTDIR)
{
	#print("$OUTDIR exists\n");
}
else
{
	print("Creating $OUTDIR\n");
	mkdir $OUTDIR;
}

# Copy in logo
copy $LOGO, $OUTDIR;

# Connect to the database
my $dbh = DBI->connect('DBI:mysql:btmux', 'btmux-read', 'abcd1234')
    or die "Couldn't open database: $DBI::errstr; stopped";

# Prepare the SQL query for execution
my $sth = $dbh->prepare(<<End_SQL) or die "Couldn't prepare statement: $DBI::errstr; stopped";
SELECT player_name, player_alias, player_online, player_idle, player_last_logon FROM players
End_SQL

# Execute the query
$sth->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year = substr($year, 1);
#printf("Time Format - HH:MM:SS\n");
$LAST_SEEN = sprintf("%02d/%02d/20%02d %02d:%02d:%02d", $mon, $mday, $year, $hour, $min, $sec);

# Write out HTML
my $message = <<"END_MESSAGE";
<html>
<head>
<title>Battletech MUX Stats For Server $SERVER_NAME</title>
<style>
body {
	background-color: #DDDDDD
}
</style>
<meta name="description" 
      content="Displays the users currently logged into the server">
<meta name="author" content="Marisa Giancarla">
<meta charset="UTF-8">
<meta name="keywords" content="battletech, utility, script, server">
<meta property="og:title" content="Battletech MUX Stats">
<meta property="og:image" content="$WEBDIR$LOGO">
<meta property="og:description" content="Displays the users currently logged into the server">
<link rel="copyright" href="https://MekCity.com/copyright.html">
</head>
<body>
<img src="$WEBDIR$LOGO"><br>
Last Scanned: $LAST_SEEN
<table border=1>
<tr><td colspan = 5><center><h1>$SERVER_NAME Server Stats</h1></center></td></tr>
<tr><td><b>User Name</b></td><td><b>User Alias</b></td><td><b>On For</b></td><td><b>Idle</b></td><td><b>Last Logon</b></td></tr>
END_MESSAGE
open(my $fh, '>', "index.html") or die "Could not open file 'index.html' $!";
print $fh $message;
#print "Operation done successfully\n";
#$dbh->disconnect();

# Fetch each row and print it
while ( my ($player_name, $player_alias, $player_online, $player_idle, $player_last_logon) = $sth->fetchrow_array() ) {
     $PlayerName = $player_name;
     print STDOUT "Field 1: $PlayerName  Field 2: $player_alias  Field 3: $player_online Field 4: $player_idle Field 5: $player_last_logon\n";
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$year = substr($year, 1);
	$LAST_SEEN = sprintf("%02d/%02d/20%02d %02d:%02d:%02d", $mon, $mday, $year, $hour, $min, $sec);

# Connect to the database
my $dbh2 = DBI->connect('DBI:mysql:joomla', 'btmux-read', 'abcd1234')
   or die "Couldn't open database: $DBI::errstr; stopped";

# Prepare the SQL query for execution
my $sth1 = $dbh2->prepare(<<End_SQL) or die "Couldn't prepare statement: $DBI::errstr; stopped";
SELECT user_id, value FROM jml_community_fields_values WHERE value = "$PlayerName"
End_SQL

# Execute the query
$sth1->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

# Fetch each row and print it
while ( my ($user_id) = $sth1->fetchrow_array() ) {
    $UserID = $user_id;
    print STDOUT "User ID: $UserID\n";

my $sth2 = $dbh2->prepare(<<End_SQL2) or die "Couldn't prepare statement: $DBI::errstr; stopped";
SELECT id, name, username FROM jml_users WHERE id = "$user_id"
End_SQL2

# Execute the User query
$sth2->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

# Fetch each row and print it
while ( my ($user_id, $user_realname, $username) = $sth2->fetchrow_array() ) {
    $RealName = $user_realname;
    print STDOUT "User Field 1: $RealName\n";


}
}

# Convert name to url format
$convertedname = ConvertName();

my $URL_IS = "https://MekCity.com/index.php/community/$UserID-$convertedname/profile";
print ("URL: '$URL_IS'\n");

# Disconnect from the database
$dbh2->disconnect();

	if ($URL_IS ne "https://MekCity.com/index.php/community/-/profile")
	{
		print $fh "<tr><td width=250><a href='$URL_IS'>$PlayerName</a></td><td>$player_alias</td><td>$player_online</td><td>$player_idle</td><td>$player_last_logon</td></tr>";
	}
	else
	{
		print $fh "<tr><td width=250>$PlayerName</td><td>$player_alias</td><td>$player_online</td><td>$player_idle</td><td>$player_last_logon</td></tr>";
	}
}

print $fh "</table>
<hr>
Max Users: $nrecord
<hr>
Version $REVVER - <b>Get This Utility At <a href=\"https://MekCity.org\">Mek City</a></b>
</body>
</html>";
close $fh;

# Disconnect from the database
$dbh->disconnect();

copy "index.html", $OUTDIR;
exit(0);

