#!/usr/bin/perl

# Reads previously fitted IPELEM file (Initial.ipelem  or InitialLLL.ipelem)
# Outputs IPELFD file
# WARNING: Assumes njj=1...N assumes WILL always use same version number


use strict;
my $efile = $ARGV[0]; #file1
my $ofile = 'Left_InitialElem16Fields_coarsemesh.ipelfd';

my $nfields = 16;

my $nelems = 32; #LUL

############### Read file 1  ######################
# Element number [    7]:     9
# The number of geometric Xj-coordinates is [3]: 3
# The basis function type for geometric variable 1 is [1]:  1
# The basis function type for geometric variable 2 is [1]:  1
# The basis function type for geometric variable 3 is [1]:  1
# Enter the 8 global numbers for basis 1:      1    65     9    79     1    66     9    80
# The version number for occurrence  1 of node     1, njj=1 is [ 1]:  1
# The version number for occurrence  1 of node     1, njj=2 is [ 1]:  1
# The version number for occurrence  1 of node     1, njj=3 is [ 1]:  1
# The version number for occurrence  1 of node    65, njj=1 is [ 1]:  2
# The version number for occurrence  1 of node    65, njj=2 is [ 1]:  2
# The version number for occurrence  1 of node    65, njj=3 is [ 1]:  2
# The version number for occurrence  1 of node     9, njj=1 is [ 1]:  1
# The version number for occurrence  1 of node     9, njj=2 is [ 1]:  1
# The version number for occurrence  1 of node     9, njj=3 is [ 1]:  1
# The version number for occurrence  2 of node     1, njj=1 is [ 1]:  2
# The version number for occurrence  2 of node     1, njj=2 is [ 1]:  2
# The version number for occurrence  2 of node     1, njj=3 is [ 1]:  2
# The version number for occurrence  1 of node    66, njj=1 is [ 1]:  2
# The version number for occurrence  1 of node    66, njj=2 is [ 1]:  2
# The version number for occurrence  1 of node    66, njj=3 is [ 1]:  2
# The version number for occurrence  2 of node     9, njj=1 is [ 1]:  2
# The version number for occurrence  2 of node     9, njj=2 is [ 1]:  2
# The version number for occurrence  2 of node     9, njj=3 is [ 1]:  2

my @map;
my @Nelem;
my @nline_store;
my @elem;
my ($nv,$nd,$elemnumber,$node,$OccurCount);

open IPELEM, "<$efile" or die "\033[31mError: Can't open $efile\033[0m ";
my $line = <IPELEM>;
my $elem_count  = 0;

while ($line) {
    if ($line =~ /Element number \[\s*(\d+)\]:\s*(\d+)/g) {
        if($elem_count > 0) {$nline_store[$elem_count] = $OccurCount;}

        $elem_count++;
        $elem[$elem_count] = $2;
        print "reading element $elem_count,$2\n";
    }
    if ($line =~ /Enter the 8 global numbers for basis 1: \s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)/g) {
        $Nelem[$elem_count][1] = $1;
        $Nelem[$elem_count][2] = $2;
        $Nelem[$elem_count][3] = $3;
        $Nelem[$elem_count][4] = $4;
        $Nelem[$elem_count][5] = $5;
        $Nelem[$elem_count][6] = $6;
        $Nelem[$elem_count][7] = $7;
        $Nelem[$elem_count][8] = $8;
        $OccurCount = 0;
       }
    if ($line =~ /The version number for occurrence\s*(\d+) of node \s*(\d+), njj=(\d) is \[\s*(\d+)\]:\s*(\d+)/g) {
       if($3 == 1) {$OccurCount++;}
       $node = $2;
       $nv = $5;
       $map[$elem_count][$OccurCount][1] = $1;
       $map[$elem_count][$OccurCount][2] = $node;
       $map[$elem_count][$OccurCount][3] = $nv;
       }
    $line = <IPELEM>;
} #while
$nline_store[$elem_count] = $OccurCount;
close IPELEM;


&Print_IPelemFIELD;






sub Print_IPelemFIELD {
#######################################################################
### write out 
#CMISS Version 2.0  ipelfd File Version 2
#Heading:

#The number of elements is [1]:    42

#Element number [    7]:     9
#The basis function type for field variable 1 is [1]:  1
#The basis function type for field variable 2 is [1]:  1
#The basis function type for field variable 3 is [1]:  1
#The basis function type for field variable 4 is [1]:  1
#Enter the 8 numbers for basis 1 [prev]:      1    65     9    79     1    66     9    80
#The version number for occurrence  1 of node     1, njj=1 is [ 1]:  1
#The version number for occurrence  1 of node     1, njj=2 is [ 1]:  1
#The version number for occurrence  1 of node     1, njj=3 is [ 1]:  1
#The version number for occurrence  1 of node     1, njj=4 is [ 1]:  1
#The version number for occurrence  1 of node    65, njj=1 is [ 1]:  2

#######################################################################

my $occur;
my $node;
my $nv;

open OPNODE, ">$ofile" or die "\033[31mError: Can't open $ofile\033[0m ";

print OPNODE " CMISS Version 2.0 ipnode File Version 2\n";
print OPNODE " Heading: fitted\n\n";
print OPNODE " The number of elements is [1]:   $nelems\n\n";

my $j=0;
foreach my $ii (1..$nelems){
  my $elemnum = $elem[$ii];

  printf OPNODE " Element number [%5d]: %5d \n",$elemnum,$elemnum;
  for my $nf (1..$nfields) {
  print OPNODE " The basis function type for field variable $nf is [1]: 1 \n";
  }

  print OPNODE " Enter the 8 numbers for basis 1 [prev]:  $Nelem[$ii][1]   $Nelem[$ii][2]   $Nelem[$ii][3]   $Nelem[$ii][4]   $Nelem[$ii][5]   $Nelem[$ii][6]   $Nelem[$ii][7]   $Nelem[$ii][8]\n"; 
  
  for my $nO (1..$nline_store[$ii]) {
  
   $occur = $map[$ii][$nO][1];
   $node = $map[$ii][$nO][2];
   $nv = $map[$ii][$nO][3];
   for my $nf (1..$nfields) {
   if($node<10) {
   print OPNODE " The version number for occurrence  $occur of node     $node, njj=$nf is [ 1]: $nv\n";}
   if($node>9 && $node<100) {
   print OPNODE " The version number for occurrence  $occur of node    $node, njj=$nf is [ 1]: $nv\n";}
   if($node>99) {
   print OPNODE " The version number for occurrence  $occur of node   $node, njj=$nf is [ 1]: $nv\n";}
                            }
   }
print OPNODE "\n";
}

close OPNODE;

}
