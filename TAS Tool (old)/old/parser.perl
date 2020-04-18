#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes 'usleep';

my $script = shift or die "Please enter script\n";
my $lock_file = "lock";
my $output_file = "/dev/ttyO1";
my $pointer = 0;

$SIG{INT} = sub {unlink $lock_file; exit 0};
$SIG{TERM} = sub {unlink $lock_file; exit 0};

# Detect lockfile
if (-e $lock_file) {die;};

# Make lockfile
open my $lockhandle, '>>', $lock_file or die;
close $lockhandle;

# Open output
open my $outputhandle, '>>', $output_file or die;
select $outputhandle;
$|--;

# Get data into array
open my $scripthandle, '<', $script or die;
chomp(my @scriptarrayinput = <$scripthandle>);
close $scripthandle;

# Actions
sub press {my $input = shift; print $input; $pointer++}
sub end {unlink $lock_file; close $outputhandle; exit 0}
sub wait2 {my $input = shift; usleep($input * 1000); $pointer++}
sub jump {my $input = shift; $pointer = $input - 1;}
sub action{my $input = shift;
	   my @temp = split / /, $input;
	   my $command = shift @temp;
	   end() if $command eq "end";
	   jump(shift @temp) if $command eq "jump";
	   wait2(shift @temp) if $command eq "wait";
	   press(shift @temp) if $command eq "press";
}

my @scriptarrayoutput;
for my $entry (@scriptarrayinput) {
    push @scriptarrayoutput, $entry if $entry =~ /^[press|end|wait|jump]/;
}

while ($pointer < @scriptarrayoutput) {
    action($scriptarrayinput[$pointer]);
}
end();

