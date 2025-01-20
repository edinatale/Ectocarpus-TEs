#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long qw(GetOptions);

#scripts takes a GFF and outputs the per transcript interesect with TEs, per transcript intersect of CDS with TEs, and the per transcript ratio of TEs to CDS
#requires GFF with genes/CDS and merged (!!) bed file of TEs
#usage: perl CDS-TE_ratio.pl --gff annotation.gff --TEs TEs_merged.bed --out CDS-TE_ratio.tsv

my $gff;
my $TEs;
my $out;

GetOptions(
	'gff=s' => \$gff,
	'TEs=s' => \$TEs,
	'out=s' => \$out,
) or die "missing input\n";

#step 1: store bed files of transcripts and CDS and store their lengths

open (IN1, "$gff") or die;
open (OUT1, ">$out") or die;
open (OUT2, ">temp_transcript.bed") or die;
open (OUT3, ">temp_CDS.bed") or die;

print OUT1 "transcript\tlength_bp\tintersect_%\tCDS_length_bp\tCDS_intersect_%\tTE_CDS_ratio\n"; #print header

my $ID;
my %transcripts;

while (my $line = <IN1>) { #loop through GFF
	chomp $line;
	unless ($line =~ /^#/) {
        	my @cols = split(/\t/, $line);
       		my @i8 = split(/\;/, $cols[8]); #split column 9
	        my $start = $cols[3] - 1; #0-based coordinate for bed files
		if ($cols[2] eq "mRNA") { #new transcript
			my @ID_cols = split(/\=/, $i8[0]);
			$ID = $ID_cols[1]; #this is the transcript ID
			if ($ID_cols[0] ne "ID") {
				print "WARNING: misformatted GFF\n$line\n";
			}
			$transcripts{$ID}{"tlength"} = $cols[4] - $start; #store transcript lengths in hash
			print OUT2 "$cols[0]\t$start\t$cols[4]\t$ID\t0\t$cols[6]\n";
		}
		elsif ($cols[2] eq "CDS") {
			my @parent_cols = split(/\=/, $i8[1]);
			if ($parent_cols[0] ne "Parent") {
				print "WARNING: misformatted GFF\n$line\n";
			}
			$transcripts{$ID}{"clength"} += $cols[4] - $start; #tally CDS length in hash
			print OUT3 "$cols[0]\t$start\t$cols[4]\t$ID\t0\t$cols[6]\n";
		}
	}
}

close IN1;
close OUT2;
close OUT3;

#step 2: intersect bed files with TE bed file and store intersect

system("bedtools intersect -a temp_transcript.bed -b $TEs > temp_TE_transcript.bed"); #intersect

open (IN2, "temp_TE_transcript.bed") or die;

while (my $l2 = <IN2>) {
	chomp $l2;
	my @c2 = split(/\t/, $l2);
	$transcripts{$c2[3]}{"tintersect"} += $c2[2] - $c2[1]; #store per ID tally of intersect
}

close IN2;

system("bedtools intersect -a temp_CDS.bed -b $TEs > temp_TE_CDS.bed"); #intersect

open (IN3, "temp_TE_CDS.bed") or die;

while (my $l3 = <IN3>) {
	chomp $l3;
	my @c3 = split(/\t/, $l3);
	$transcripts{$c3[3]}{"cintersect"} += $c3[2] - $c3[1]; #store per ID tally of intersect
}

close IN3;

#step 3: calculate percent intersect and ratio

foreach my $transcript (keys %transcripts) {
	my $tpercent = 0;
	my $cratio = "NA";
	if ( (exists $transcripts{$transcript}{"tintersect"}) and (exists $transcripts{$transcript}{"clength"}) ) {
		$tpercent = ($transcripts{$transcript}{"tintersect"} / $transcripts{$transcript}{"tlength"} ) * 100;
		$cratio = $transcripts{$transcript}{"tintersect"} / $transcripts{$transcript}{"clength"};
	}
	else {
		next;
	}
	my $cpercent = 0;
	if (exists $transcripts{$transcript}{"cintersect"}) {
		$cpercent = ($transcripts{$transcript}{"cintersect"} / $transcripts{$transcript}{"clength"} ) * 100;
	}
	print OUT1 "$transcript\t$transcripts{$transcript}{tlength}\t$tpercent\t$transcripts{$transcript}{clength}\t$cpercent\t$cratio\n";
}

close OUT1;

exit;
