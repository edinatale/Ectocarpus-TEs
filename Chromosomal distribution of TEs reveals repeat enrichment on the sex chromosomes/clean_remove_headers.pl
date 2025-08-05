#!/usr/bin/perl
 
use warnings;
use strict;
use Getopt::Long qw(GetOptions);
use Data::Dumper;
 
my $headers;
my $fa;
my $remove;
my $out;
 
 
GetOptions(
	'headers=s' => \$headers,
	'fa=s' => \$fa,
	'remove=s' => \$remove,
	'out=s' => \$out,
) or die "missing input\n";
 
#usage: perl clean_remove_headers.pl --headers headers.tsv --fa in.fa --remove virus_1,sawer --out out.fa
 
#step 1: store the list of sequences to remove in a dictionary
 
my @bads = split(/\,/, $remove); #split list of seqs to remove
my %filter;
 
foreach my $bad (@bads) { #add list of seqs to remove to a dictionary
	$filter{$bad} = 1;
}
 
#step 2: make a dictionary of the original class (key) and the replacement class (value)
 
my %change;
 
open (IN1, "$headers") or die; #open headers file
 
while (my $l1 = <IN1>) { #read through file line by line
	chomp $l1;
	my @c1 = split(/\t/, $l1); #split columns by tab
	$change{$c1[0]} = $c1[1]; #make dictionary with original class as key and new class as value
}
 
close IN1;
 
#step 3: modify fasta headers with new classes and filter out sequences we don't want
 
open (IN2, "$fa") or die; #open files for reading and writing
open (OUT, ">$out") or die;
 
my $print = 0;
 
while (my $l2 = <IN2>) {
	chomp $l2;
	if ($l2 =~ /^>/) { #if it's a header
		$print = 1;
		my @hcols = split(/\#/, $l2); #split on #
		my $family = substr $hcols[0], 1; #remove > from family
		if (exists $filter{$family}) { #is this a header/sequence we want to remove?
			$print = 0;
			print "$family has been removed\n";
		}
		else { #this is a good sequence
			$hcols[1] =~ s/\s+$//;
			if (exists $change{$hcols[1]}) { #is this class in the list to be replaced?
				my $replace = $hcols[0] . "#" . $change{$hcols[1]}; #make a new header
				print OUT "$replace\n";
			}
			else { #class isn't in list of headers, print it as it is but write a message to stdout to check it
				print "$l2\n"; 
				print "is this really a header that should be left as it is?\n";
				print OUT "$l2\n";
			}
		}
	}
	elsif ($print == 1) { #this is a good sequence to keep
		print OUT "$l2\n";
	}
}
 
close IN2;
close OUT;
 
exit;
