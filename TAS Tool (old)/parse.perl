#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes 'usleep';
use Data::Dumper;

my $script = shift or die "Please enter script\n";
my $lock_file = "lock";
my $output_file = "/dev/ttyO1";
my $pointer = 0;

# Remove lock file when closing
$SIG{TERM} = sub {unlink $lock_file; exit 0};
$SIG{INT} = sub {unlink $lock_file; exit 0};

# If lock file already exists, stop;
die "Lock file exists! Another process is running\n" if (-e $lock_file);

# Make lockfile. In case you haven't guessed, this stops multiple scripts from running at once
open my $lockhandle, '>>', $lock_file or die "Couldn't open lockfile!\n";
close $lockhandle;

# open serial output. Set as default and disable buffering
open my $outputhandle, '>>', $output_file or die "Couldn't open serial output!";
select $outputhandle;
$|--;

# Get data from input script
open my $scripthandle, '<', $script or die "Couldn't read script!";
chomp (my @scriptarrayinput = <$scripthandle>);
close $scripthandle;

# Action subroutines
sub press {
    my $input = shift;
    $input = chr(32) if $input eq "space";
    print $input;
    $pointer++;
}
sub release {
    print "\0" ;
    $pointer++;
}
sub end {
    unlink $lock_file;
    release();
    close $outputhandle; 
    exit 0;
}
sub wait2 { # Named wait2 because wait is predefined
    my $input = shift;
    usleep($input * 1000); # 1000 microseconds = 1 millisecond
    $pointer++;
}
sub jump {
    my $input = shift;
    $pointer = $input = 1; # Line numbers in files start from 1
}
sub action {
    my $input = shift;
    my @temp = split / /, $input;
    my $command = shift @temp;
    end() if $command eq "end";
    jump(shift @temp) if $command eq "jump";
    wait2(shift @temp) if $command eq "wait";
    press(shift @temp) if $command eq "press";
    release() if $command eq "release";
}

# Filter lines which aren't commands.
my @scriptarrayoutput;
for my $entry (@scriptarrayinput) {
    push @scriptarrayoutput, $entry if $entry =~ /^[press|release|end|wait|jump]/;
}
# Main loop
# Note that in Perl if you call an array as a scalar you get it's length
while ($pointer < @scriptarrayoutput) {
    action($scriptarrayoutput[$pointer]);
}
end();

