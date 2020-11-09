#!/usr/bin/perl

# Reads previously fitted mesh (LLL_fitted.ipnde  OR Left_fitted)
# Uses ONLY number of versions info on each node
# Outputs ipfiel file

use strict;
my $efile = $ARGV[0];
#my $ofile = 'LUL_ApexNoInnerVersLUL_Initialize16Fields.ipfiel';
my $ofile = 'Left_Initialize16Fields_coarsemesh.ipfiel';

my $nfields = 16;

my $NumberofNodes = 47; #LUL

############### Read file 1  ######################
my @map;
my @nodes;
my @nlines;
my @nv;
my ($nd,$nodenumber,$nver);

open IPELEM, "<$efile" or die "\033[31mError: Can't open $efile\033[0m ";
my $line = <IPELEM>;
my $char_count  = -1;
my $node_count  = 0;
while ($line) {
    if ($line =~ /Node number \[.*\]:\s*(\d+)/) {
        $node_count++;
        $nodes[$node_count] = $1;
    }
    if ($line =~ /The number of versions for nj=(\d) is \[.*\]:\s*(\d+)/) {
        if($2 == 1) {$char_count  = 0;}
        $nd = $1;
        $nver = 1; #incase of no multiple versions
        $nv[$nodes[$node_count]] = $2;
        print "$nodes[$node_count],$1,$2 \n";
       }
    if ($line =~ /For version number (\d):/) {
        $char_count  = 0;
        $nver = $1;
       }
    if($char_count  == 0) {$line = <IPELEM>;}
    if($char_count >= 0) {
    $char_count++;
    $nodenumber = $nodes[$node_count];
    $map[$nodenumber][$nd][$nver][$char_count] = $line;}

    $line = <IPELEM>;
} #while
close IPELEM;


&Print_IPFIELD;






sub Print_IPFIELD{
#######################################################################
### write out 
#######################################################################

open OPNODE, ">$ofile" or die "\033[31mError: Can't open $ofile\033[0m ";

print OPNODE " CMISS Version 2.1 ipnode File Version 3\n";
print OPNODE " Heading: fitted\n\n";
printf OPNODE " The number of field variables is [5]:%3d\n",$nfields;
printf OPNODE " The number of nodes is [    70]:%7d\n",$NumberofNodes;
for my $nf (1..$nfields) {
print OPNODE " Do you want prompting for different versions of field variable $nf [N]? Y\n";
}
for my $nf (1..$nfields) {
print OPNODE " The number of derivatives for field variable $nf is [0]: 7\n";
}
print OPNODE "  \n";

my $j=0;
foreach my $ii (1..$NumberofNodes){
  my $nodenum = $nodes[$ii];

  printf OPNODE " Node number [%6d]: %6d\n",$nodenum,$nodenum;
  for my $nf (1..$nfields) {
  printf OPNODE " The number of versions for field variable $nf is [1]:%3d\n",$nv[$nodenum];

  for ($nver = 1; $nver <= $nv[$nodenum]; $nver++)
    {
    print OPNODE " For version number $nver: \n"; 
    print OPNODE " The field variable $nf value is [ 0.00000E+00]:  0.00000E+00\n"; 
    print OPNODE " The derivative wrt direction 1 is [ 0.00000E+00]:  0.00000E+00\n";
    print OPNODE " The derivative wrt direction 2 is [ 0.00000E+00]:  0.00000E+00\n";
    print OPNODE " The derivative wrt directions 1 & 2 is [ 0.00000E+00]:  0.00000E+00\n";
    print OPNODE " The derivative wrt direction 3 is [ 0.00000E+00]:  0.00000E+00\n";
    print OPNODE " The derivative wrt directions 1 & 3 is [ 0.00000E+00]:  0.00000E+00\n";
    print OPNODE " The derivative wrt directions 2 & 3 is [ 0.00000E+00]:  0.00000E+00\n";
    print OPNODE " The derivative wrt directions 1, 2 & 3 is [ 0.00000E+00]:  0.00000E+00\n";
}
}
print OPNODE "\n";
}

close OPNODE;

}
