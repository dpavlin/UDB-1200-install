#!/usr/bin/perl
use warnings;
use strict;

my $in_read = 0;
my $wait = 0;
my $read = '';

use Data::Dump qw(dump);

sub hex2ascii {
	my $hex = shift;
	my $ascii;
	$ascii .= chr(hex($_)) foreach ( split(/\s+/,$hex) );
	return dump($ascii);
}

while(<>) {
	s/[\n\r]+$//;

	s/\s+(\S+).exe\s+//g;

	my $time = $1 if /(\d+:\d+:\d+)/;
	$time .= ' | ';

	if ( /IRP_MJ_WRITE.*:\s*(.*)/ ) {
		print ">> $time $1", hex2ascii($1), "\n";
	} elsif ( /(IRP_MJ_READ|IOCTL_SERIAL_WAIT_ON_MASK)/ ) {
		$in_read++;
		print "#[$in_read] $_\n";
	}
	# can have SUCCESS in same line!
	if (  $in_read && /SUCCESS\s+Length\s+\d+:\s*([0-9a-fA-F\s]+)/ ) {
		$read .= $1;
		print "#<$in_read $_\n";
		my $len = hex($1) if ( $read =~ m/^([0-9a-f]{2})/i );
		print "#< $read [$len]\n";
		print "<< $time $read", hex2ascii($read), "\n";
		$in_read = 0;
		$read = '';
	} else {
		print "# $_\n";
	}
}
