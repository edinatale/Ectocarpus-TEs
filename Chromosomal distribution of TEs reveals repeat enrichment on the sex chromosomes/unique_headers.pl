#!/usr/bin/perl
 
use warnings;
use strict;
use Getopt::Long qw(GetOptions);
use Data::Dumper;
 
#usage: perl unique_repeat_headers.pl --fasta in.fa --out out.fa
 
my $fasta;
my $out;
 
GetOptions(
	'fasta=s' => \$fasta,
	'out=s' => \$out,
) or die "missing input\n";
 
my $count = 0;
 
open (IN, "$fasta") or die;
open (OUT, ">$out") or die;
 
while (my $line = <IN>) {
	chomp $line;
	if ($line =~/^>/) { #if it is a header
		my $id = substr $line, 1; #remove ">" character
		$count++; #increment the counter by +1
		my $digits = sprintf("%03d", $count); #make it a three digit number
		my $unique = "family" . $digits . "#"; #make a unique name
		my $header = ">" . $unique . $id; #make final header
		print OUT "$header\n";
	}
	else {
		print OUT "$line\n";
	}
}
 
close IN;
close OUT;
 
exit;
