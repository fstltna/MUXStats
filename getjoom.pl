#!/usr/bin/perl

use strict;

use DBI;
my $DESIRED_NAME = "MarisaG";
my $UserID;
my $RealName;
my $convertedname;

sub ConvertName ()
{
	my $OutputName;

	$OutputName = lc($RealName);
	$OutputName =~s/ /-/g;
	return($OutputName);
}

# Connect to the database
my $dbh2 = DBI->connect('DBI:mysql:joomla', 'btmux-read', 'abcd1234')
    or die "Couldn't open database: $DBI::errstr; stopped";

# Prepare the SQL query for execution
my $sth1 = $dbh2->prepare(<<End_SQL) or die "Couldn't prepare statement: $DBI::errstr; stopped";
SELECT user_id, value FROM jml_community_fields_values WHERE value = "$DESIRED_NAME"
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

exit(0);
