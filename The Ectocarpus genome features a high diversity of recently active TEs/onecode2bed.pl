#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long qw(GetOptions);

#script converts one code output to bed file, enabling intersection with beds for intergenic, introns, etc. 
#will also store lengths and divergence of every copy
#usage: perl onecode2bed.pl --onecode onecode.csv --bed onecode.bed --out onecode_lengths_divergence.tsv

my $onecode;
my $bed;
my $out;

GetOptions(
	'onecode=s' => \$onecode,
	'bed=s' => \$bed,
	'out=s' => \$out,
) or die "missing input\n";

#part 1: make a bed file

open (IN, "$onecode") or die;
open (OUT1, ">$bed") or die; #this is the bed file output

my %lengths; #dictionary to store lengths
my %divergence; #dictionary to store divergence
my %counter; #a counter for each TE copy of each family
my %location; #a dictionary of coordinates (merged!)

my $copyID;
my $strand;
my $merge = 0;
my $start1; #added by Erica because of error

while (my $line = <IN>) { #loop through file
	chomp $line;
	my @cols = split(" ", $line); #split line to cols on spaces
	if ($line =~ /^###/) { #this is an element
	my $start1 = $cols[5] - 1; #moved by Erica
		$counter{$cols[9]}++; #a running count for every family to make a unique copy ID
		$copyID = $cols[9] . "." . $counter{$cols[9]}; #ID is familyname.copynumber
		if ($cols[8] eq "+") { #store strand
			$strand = "+";
		}
		else {
			$strand = "-";
		}
		if ($cols[0] =~ /\//) { #this is a merged element, need to access individual sub-parts
			$merge = 1;
		}
		else {
			$merge = 0;
			#my $start1 = $cols[5] - 1;
			print OUT1 "$cols[4]\t$start1\t$cols[6]\t$copyID\t0\t$strand\n"; #print the bed line for unmerged
			my $length1 = $cols[6] - $start1;
			$lengths{$copyID} = $length1; #for unmerged, we can now store the length
		}
		$divergence{$copyID} = $cols[1]; #for both unmerged and merged, can take divergence from ### line
		my $info = "$cols[4]\t$start1\t$cols[6]\t$strand";
		$location{$copyID} = $info;
	}
	elsif ( ($merge == 1) and  ($line ne '') and ($cols[0] ne "Score") ) { #these lines contain the sub-parts of the merged element
		my $start2 = $cols[5] - 1;
		print OUT1 "$cols[4]\t$start2\t$cols[6]\t$copyID\t0\t$strand\n"; #print the bed line for merged sub-part
		my $length2 = $cols[6] - $start2;
		$lengths{$copyID}+= $length2; #cumulate length
	}
}

close IN;
close OUT1;

#part 2: make a tsv file with lengths and divergence

open (OUT2, ">$out") or die;

foreach my $copy (keys %divergence) { #loop through keys of divergence hash, $copy = $copyID
	print OUT2 "$copy\t$location{$copy}\t$lengths{$copy}\t$divergence{$copy}\n";
}

close OUT2;

exit;

