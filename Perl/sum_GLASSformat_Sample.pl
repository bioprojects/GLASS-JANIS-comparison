#! /usr/local/bin/perl

use lib '~/cpan';
use Data::Dumper;
use Getopt::Std;
use Tie::IxHash;
use Bio::SeqIO;
use strict;
use warnings;

use vars qw ($opt_f $opt_l $opt_v);
&getopts('f:l:v');

my $usage = <<_EOH_;

# -f GLASS_2017_dupJANIS_patientGLASSSummary_20190411123215.csv

# [-v]

_EOH_
;

#
# IN
#

my $inFile  = $opt_f or die $usage;

my $header = "";
tie my %hash_out, 'Tie::IxHash';

tie my %hash_order_SPECIMEN, 'Tie::IxHash';
tie my %hash_order_PATHOGEN, 'Tie::IxHash';
tie my %hash_order_SEX, 'Tie::IxHash';
tie my %hash_order_ORIGIN, 'Tie::IxHash';
tie my %hash_order_AGEGROUP, 'Tie::IxHash';
tie my %hash_order_ANTIBIOTIC, 'Tie::IxHash';

#
# remove BOM
#
my $cmd = "nkf --overwrite --oc=UTF-8 $inFile";
#print("$cmd\n");
system("$cmd");

#
# first, store all target hot loci into a hash
#
my %hash_header_name2colIndex =();
$header=`head -1 $inFile`;
chomp($header);
my @arr_header = split(/,/, $header, -1);
my $num_arr_header = @arr_header;
for (my $i=0; $i<$num_arr_header; $i++) {
  $hash_header_name2colIndex{ $arr_header[$i] } = $i;
}

open(IN, "tail -n +2 $inFile |");
while (my $line = <IN>) {
  chomp $line;
  my @arr_line = split(/,/, $line, -1);

if (!defined($hash_header_name2colIndex{"YEAR"})) {
  print Dumper(\%hash_header_name2colIndex);
  print $hash_header_name2colIndex{"YEAR"} . "\n";
  print $arr_line[ $hash_header_name2colIndex{"YEAR"} ] . "\n";
  exit(0);
}

  my $YEAR     = $arr_line[ $hash_header_name2colIndex{"YEAR"} ];
  my $SPECIMEN = $arr_line[ $hash_header_name2colIndex{"SPECIMEN"} ];
#  my $PATHOGEN = $arr_line[ $hash_header_name2colIndex{"PATHOGEN"} ];
#  my $GENDER      = $arr_line[ $hash_header_name2colIndex{"GENDER"} ];
  my $ORIGIN   = $arr_line[ $hash_header_name2colIndex{"ORIGIN"} ];
  my $AGEGROUP_ori = $arr_line[ $hash_header_name2colIndex{"AGEGROUP"} ];
#  my $ANTIBIOTIC = $arr_line[ $hash_header_name2colIndex{"ANTIBIOTIC"} ];

  my $AGEGROUP = "";
  # 14歳以下 or 15～64歳 or 65歳以上
  if ($AGEGROUP_ori eq "<1" ||
      $AGEGROUP_ori eq "01<04" ||
      $AGEGROUP_ori eq "05<14") {
    $AGEGROUP = "~14";
  } elsif ($AGEGROUP_ori eq "15<24" ||
      $AGEGROUP_ori eq "25<34" ||
      $AGEGROUP_ori eq "35<44" || 
      $AGEGROUP_ori eq "45<54" ||
      $AGEGROUP_ori eq "55<64") {
    $AGEGROUP = "15~64";
  } else {
    $AGEGROUP = "65~";
  } 

  if (!defined($hash_order_SPECIMEN{$SPECIMEN})) {
    $hash_order_SPECIMEN{$SPECIMEN} = 1;
  }

  if (!defined($hash_order_ORIGIN{$ORIGIN})) {
    $hash_order_ORIGIN{$ORIGIN} = 1;
  }

  if (!defined($hash_order_AGEGROUP{$AGEGROUP})) {
    $hash_order_AGEGROUP{$AGEGROUP} = 1;
  }

  my $NUMSAMPLEDPATIENTS = $arr_line[ $hash_header_name2colIndex{"NUMSAMPLEDPATIENTS"} ];

  if (!defined($hash_out{$YEAR}{$SPECIMEN}{$ORIGIN}{$AGEGROUP}{"NUMSAMPLEDPATIENTS"}))  {
    $hash_out{$YEAR}{$SPECIMEN}{$ORIGIN}{$AGEGROUP}{"NUMSAMPLEDPATIENTS"} = $NUMSAMPLEDPATIENTS;
  } else {
    $hash_out{$YEAR}{$SPECIMEN}{$ORIGIN}{$AGEGROUP}{"NUMSAMPLEDPATIENTS"} += $NUMSAMPLEDPATIENTS;
  }

}

#
# output
#
print "YEAR,ORIGIN,AGEGROUP,SPECIMEN,NUMSAMPLEDPATIENTSS\n";

foreach my $YEAR (sort keys %hash_out) {

  foreach my $ORIGIN (keys %hash_order_ORIGIN) {
    foreach my $AGEGROUP (keys %hash_order_AGEGROUP) {
      foreach my $SPECIMEN (keys %hash_order_SPECIMEN) {

        if (defined($hash_out{$YEAR}{$SPECIMEN}{$ORIGIN}{$AGEGROUP})) {
          my $out_line = "$YEAR,$ORIGIN,$AGEGROUP,$SPECIMEN";
             $out_line .= "," . $hash_out{$YEAR}{$SPECIMEN}{$ORIGIN}{$AGEGROUP}{"NUMSAMPLEDPATIENTS"};
          print $out_line . "\n";
        }

      }
    }
  }

}

