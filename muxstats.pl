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

# Load our dependancies
#use strict;
use File::Copy qw(copy);
use Net::Telnet();

my ($t, @output);

# Code below here
if (-e $OUTDIR and -d $OUTDIR)
{
	print("$OUTDIR exists\n");
}
else
{
	print("Creating $OUTDIR\n");
	mkdir $OUTDIR;
}

# Copy in logo
copy $LOGO, $OUTDIR;

$first_row = 1;

	$t = new Net::Telnet (Timeout  => 10,
						  Port => $SERVERPORT,
			              Prompt => "/'/",
			              Telnetmode => 0
#						  ErrMode => "return"
		);
	## Connect and login.
	$t->open($SERVERHOST);
	print "Server: $SERVERHOST\n";
	print "Port: $SERVERPORT\n";
	do {
		$line = $t->getline();
		print $line;
	}until ($line =~ /\'?$/);
	$t->print(('WHO'));
	@output = ();
	$nrecord = 0;
	while(1) {
		$line = $t->getline();
		if($line =~ /^Player Name\s+On For\s+Idle\s+.*/) {
			next;
		}
		if ($line =~ /^\d+ Players logged in, (\d+) record, .*/) {
			$nrecord = $1;
			last;
		}
		if($line =~ /^(\S+(\s+\S+)?)\s+(\d{2,2}:\d{2,2})\s+(\d+[smhd]\S*)\s+(.*)/) {
			push @output, ($1, $3, $4, $5)
		}else {
			print("Opps, not match ????????\n");
		}
	};
	print("record=$nrecord\n");
	print("output = @output\n");
	$t->close;
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
	background-color: #DDD757
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
<tr><td colspan = 4><center><h1>$SERVER_NAME Server Stats</h1></center></td></tr>
<tr><td><b>User Name</b></td><td><b>On For</b></td><td><b>Idle</b></td><td><b>Status</b></td></tr>
END_MESSAGE
open(my $fh, '>', "index.html") or die "Could not open file 'index.html' $!";
print $fh $message;
print "Operation done successfully\n";
#$dbh->disconnect();

foreach $curline (@output)
{
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$year = substr($year, 1);
	$LAST_SEEN = sprintf("%02d/%02d/20%02d %02d:%02d:%02d", $mon, $mday, $year, $hour, $min, $sec);
	print $fh "<tr><td width=250>$curline</td><td>$ONFOR</td><td>$IDLE</td><td>$STATUS</td></tr>";
}

print $fh "</table>
<hr>
Max Users: $nrecord
<hr>
Version $REVVER - <b>Get This Utility At <a href=\"https://MekCity.org\">Mek City</a></b>
</body>
</html>";
close $fh;
copy "index.html", $OUTDIR;
exit(0);

