#!/usr/bin/perl

use utf8;
use 5.014;

# @source https://www.perlmonks.org/?part=1;abspart=1;node_id=258877;displaytype=displaycode
my %User;
{
	local @ARGV;    
	@ARGV = qw(/etc/passwd);    
	while (<>) {
		chomp;
		my @field = split /:/;
		unless (exists $User{$field[0]}) {
			$User{$field[0]} = \@field;
		}
		else {
			print "WARNING:  Duplicate found for $field[0]\n";
		}
	}
}

# we go about creating the new user 
print "Type new user name: ";
chomp(my $userToCheck = <STDIN>);

# user empty input
if($userToCheck eq "") {
	print "ERROR: empty strings don't count as user...";
	exit 1;
}

# user already exists 
if (exists $User{$userToCheck}) {
	print "ERROR: $userToCheck already exists on this system!\n";
	exit 2;
}

# adding user
system "sudo adduser $userToCheck";

print "$userToCheck has been created \n";
print "/home/$userToCheck has been created\n";

# grant user with sudo privileges ?
print "Add user to wheel (sudo) group ? (y/n)";
chomp(my $sudoer = <STDIN>);

my $lowSudoer = lc $sudoer;
my @acceptableAnswers = ("y", "n");

if ($lowSudoer ~~  @acceptableAnswers) {
	 system "sudo usermod -aG wheel $userToCheck";
	 print "$userToCheck has been granted sudo privileges.\n";
} else {
  	 print "ERROR: y/n are the only possible answers.\nNow exiting.\n";
	 print "$userToCheck has nonetheless been created WITHOUT sudo privileges.\n";
	 exit 1;
       }
         print "Generating permissions for /home/$userToCheck\n";
 	 system "sudo chown $userToCheck:$userToCheck /home/$userToCheck";

	 print "Generating new password for $userToCheck\n";
	 system "sudo passwd $userToCheck";
	
	 # expire password after first login
	 system "sudo passwd -e $userToCheck";

	 print "Temporary password created, now exiting the user creation script.\n";
