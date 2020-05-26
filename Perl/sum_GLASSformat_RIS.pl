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

# -f GLASS_2017_dupJANIS_bacteriaDrugGLASSSummary_20190411123215.txt_REFINE.csv | 

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

  my $YEAR     = $arr_line[ $hash_header_name2colIndex{"YEAR"} ];
  my $SPECIMEN = $arr_line[ $hash_header_name2colIndex{"SPECIMEN"} ];
  my $PATHOGEN = $arr_line[ $hash_header_name2colIndex{"PATHOGEN"} ];
#  my $SEX      = $arr_line[ $hash_header_name2colIndex{"SEX"} ];
  my $ORIGIN   = $arr_line[ $hash_header_name2colIndex{"ORIGIN"} ];
  my $AGEGROUP_ori = $arr_line[ $hash_header_name2colIndex{"AGEGROUP"} ];
  my $ANTIBIOTIC = $arr_line[ $hash_header_name2colIndex{"ANTIBIOTIC"} ];

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

  if (!defined($hash_order_PATHOGEN{$PATHOGEN})) {
    $hash_order_PATHOGEN{$PATHOGEN} = 1;
  }

#  if (!defined($hash_order_SEX)) {
#    $hash_order_SEX = 1;
#  }

  if (!defined($hash_order_ORIGIN{$ORIGIN})) {
    $hash_order_ORIGIN{$ORIGIN} = 1;
  }

  if (!defined($hash_order_AGEGROUP{$AGEGROUP})) {
    $hash_order_AGEGROUP{$AGEGROUP} = 1;
  }

  if (!defined($hash_order_ANTIBIOTIC{$ANTIBIOTIC})) {
    $hash_order_ANTIBIOTIC{$ANTIBIOTIC} = 1;
  }

  my $RESISTANT = $arr_line[ $hash_header_name2colIndex{"RESISTANT"} ];
  my $INTERMEDIATE = $arr_line[ $hash_header_name2colIndex{"INTERMEDIATE"} ];
  my $NONSUSCEPTIBLE = $arr_line[ $hash_header_name2colIndex{"NONSUSCEPTIBLE"} ];
  my $SUSCEPTIBLE = $arr_line[ $hash_header_name2colIndex{"SUSCEPTIBLE"} ];
  my $UNKNOWN_NO_AST = $arr_line[ $hash_header_name2colIndex{"UNKNOWN_NO_AST"} ];
  my $UNKNOWN_NO_BREAKPOINTS = $arr_line[ $hash_header_name2colIndex{"UNKNOWN_NO_BREAKPOINTS"} ];

  if (!defined($hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"RESISTANT"}))  {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"RESISTANT"} = $RESISTANT;
  } else {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"RESISTANT"} += $RESISTANT;
  }

  if (!defined($hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"INTERMEDIATE"}))  {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"INTERMEDIATE"} = $INTERMEDIATE;
  } else {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"INTERMEDIATE"} += $INTERMEDIATE;
  }

  if (!defined($hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"NONSUSCEPTIBLE"}))  {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"NONSUSCEPTIBLE"} = $NONSUSCEPTIBLE;
  } else {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"NONSUSCEPTIBLE"} += $NONSUSCEPTIBLE;
  }

  if (!defined($hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"SUSCEPTIBLE"}))  {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"SUSCEPTIBLE"} = $SUSCEPTIBLE;
  } else {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"SUSCEPTIBLE"} += $SUSCEPTIBLE;
  }

  if (!defined($hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"UNKNOWN_NO_AST"}))  {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"UNKNOWN_NO_AST"} = $UNKNOWN_NO_AST;
  } else {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"UNKNOWN_NO_AST"} += $UNKNOWN_NO_AST;
  }

  if (!defined($hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"UNKNOWN_NO_BREAKPOINTS"}))  {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"UNKNOWN_NO_BREAKPOINTS"} = $UNKNOWN_NO_BREAKPOINTS;
  } else {
    $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"UNKNOWN_NO_BREAKPOINTS"} += $UNKNOWN_NO_BREAKPOINTS;
  }

}

#
# output
#
print "YEAR,ORIGIN,AGEGROUP,SPECIMEN,PATHOGEN,ANTIBIOTIC,RESISTANT,INTERMEDIATE,NONSUSCEPTIBLE,SUSCEPTIBLE,UNKNOWN_NO_AST,UNKNOWN_NO_BREAKPOINTS\n";

foreach my $YEAR (sort keys %hash_out) {

  foreach my $ORIGIN (keys %hash_order_ORIGIN) {
    foreach my $AGEGROUP (keys %hash_order_AGEGROUP) {
      foreach my $SPECIMEN (keys %hash_order_SPECIMEN) {
        foreach my $PATHOGEN (keys %hash_order_PATHOGEN) {
            foreach my $ANTIBIOTIC (keys %hash_order_ANTIBIOTIC) {
              if (defined($hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC})) {
                my $out_line = "$YEAR,$ORIGIN,$AGEGROUP,$SPECIMEN,$PATHOGEN,$ANTIBIOTIC";
                   $out_line .= "," . $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"RESISTANT"};
                   $out_line .= "," . $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"INTERMEDIATE"};
                   $out_line .= "," . $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"NONSUSCEPTIBLE"};
                   $out_line .= "," . $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"SUSCEPTIBLE"};
                   $out_line .= "," . $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"UNKNOWN_NO_AST"};
                   $out_line .= "," . $hash_out{$YEAR}{$SPECIMEN}{$PATHOGEN}{$ORIGIN}{$AGEGROUP}{$ANTIBIOTIC}{"UNKNOWN_NO_BREAKPOINTS"};
                print $out_line . "\n";
              }
            }
        }
      }
    }
  }

}

