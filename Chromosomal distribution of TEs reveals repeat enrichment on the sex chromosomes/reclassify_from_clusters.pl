#!/usr/bin/perl
 
use warnings;
use strict;
use Getopt::Long qw(GetOptions);
use Data::Dumper;
 
#usage: perl reclassify_from_clusters.pl --clusters clusters.txt --library in.fa --out out.fa --log log.txt
 
my $clusters;
my $library;
my $out;
my $log;
 
GetOptions(
	'clusters=s' => \$clusters,
	'library=s' => \$library,
	'out=s' => \$out,
	'log=s' => \$log,
) or die "missing input\n";
 
open (IN1, "$clusters") or die; 
 
my %old; #stores old names of families in their clusters (cluster is key, names are elements)
my %change; #if there is a manually curated element in cluster, store new classification (cluster is key, new class is element)
 
my $cluster_name;
 
while (my $line1 = <IN1>) { #loop through clusters file
	chomp $line1;
	if ($line1 =~ /^>Cluster/) { #line is a new cluster
		$cluster_name = substr $line1, 1; #remove ">" character, store cluster name
	}
	else { #these lines are within a cluster
		my @cols1 = split(" ", $line1); #split line into array on each white space
		my @subcols1 = split(/\#/, $cols1[2]); #split family name on # character
		my $family = substr $subcols1[0], 1; #remove ">" from family name
		push @{ $old{$cluster_name} }, $family; #adding family names (elements) to their respective cluster name (key)
		if ($family !~ /^fam/) { #names of all old models start with family, so this selects manually curated ones
			my $class = substr($subcols1[1], 0, -3); #remove the trailing "..." from order/superfamily classification
			if (exists $change{$cluster_name}) { #this is not the first manual model in the cluster
				unless ($change{$cluster_name} eq $class) { #is the classification consistent?
					print "$cluster_name\n"; #if it's inconsistent, print to stdout so we can check manually
				}
			}
			else { #this is the first manually curated element in cluster
				$change{$cluster_name} = $class; #make a dictionary with cluster_name as key, and class as value
			}
		}
	}
}
 
close IN1;
 
my %new_class; #dictionary with each family to change (key) and the new class (element)
 
foreach my $cluster_change (keys %change) { #loop through dictionary of all the clusters with changes
	foreach my $family_change (@{ $old{ $cluster_change } }) { #loop through array of families in the cluster
		if ($family_change =~ /^fam/) { #only going to change old models, not manual models
			$new_class{$family_change} = $change{$cluster_change}; #save each family to be changed with the new class
		}
	}
}
 
open (IN2, "$library") or die;
open (OUT1, ">$out") or die;
open (OUT2, ">$log") or die;
 
while (my $line2 = <IN2>) { #loop through all lines of the libraru
	chomp $line2;
	if ($line2 =~ /^>/) { #line is a header
		my @subcols2 = split(/\#/, $line2); #split on #
		my $family_check = substr $subcols2[0], 1; #remove ">"
		if (exists $new_class{$family_check}) { #is this family one to change?
			my $new_header = ">" . $family_check . "#" . $new_class{$family_check}; #make new header with changed class
			print OUT1 "$new_header\n"; #print new header
			chomp $subcols2[1];
			print OUT2 "$family_check\t$subcols2[1]\t$new_class{$family_check}\n"; #print log file with old and new class
		}
		else {
			print OUT1 "$line2\n"; #not changing, print as it is
		}
	}
	else { #this is sequence, not header
		print OUT1 "$line2\n";
	}
}
 
close IN2;
close OUT1;
close OUT2;
 
exit;
