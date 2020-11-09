#!/usr/bin/perl

# Scales the location of internal nodes during fitting

use strict;
my $nfrcfile = $ARGV[0]; #input node file
my $ntlcfile = $ARGV[1]; #input node file

my $ncnt = 0;

# Process nodes
open IPNODE, "<$nfrcfile" or die "\033[31mError: Can't open file\033[0m ";
my (@node, $i, $nccn, %xyzFRC, $nv, @derivFRC, %xyzTLC, @derivTLC, @versions);

my $line = <IPNODE>;
while ($line) {
    if ($line =~ /Node number \[\s*\d+\]:\s*(\d+)/) {
       $ncnt = $ncnt + 1;
       $node[$ncnt] = $1;
       $nccn = $node[$ncnt];
       $nv = 1;
       $versions[$nccn] = $nv;
    }
    if ($line =~ /For version number (\d):/) {
         $nv = $1;
         $versions[$nccn] = $nv;}
    if ($line =~ /The Xj\((\d)\) coordinate is \[.*\]:\s*(.*)/){
	$i = $1;
	$xyzFRC{$nccn}->[$i] = $2;
       print "$i \n";
    }    
    if ($line =~ /The derivative wrt direction 1 is \[.*\]:\s*(.*)/) {$derivFRC[$nccn][$nv][$i][1] = $1;}
    if ($line =~ /The derivative wrt direction 2 is \[.*\]:\s*(.*)/) {$derivFRC[$nccn][$nv][$i][2] = $1;}
    if ($line =~ /The derivative wrt directions 1 \& 2 is \[.*\]:\s*(.*)/) {$derivFRC[$nccn][$nv][$i][3] = $1;}
    if ($line =~ /The derivative wrt direction 3 is \[.*\]:\s*(.*)/) {$derivFRC[$nccn][$nv][$i][4] = $1;}
    if ($line =~ /The derivative wrt directions 1 \& 3 is \[.*\]:\s*(.*)/) {$derivFRC[$nccn][$nv][$i][5] = $1;}
    if ($line =~ /The derivative wrt directions 2 \& 3 is \[.*\]:\s*(.*)/) {$derivFRC[$nccn][$nv][$i][6] = $1;}
    if ($line =~ /The derivative wrt directions 1, 2 \& 3 is \[.*\]:\s*(.*)/) {$derivFRC[$nccn][$nv][$i][7] = $1;}
    $line = <IPNODE>;    

}
close IPNODE;

#my $x72 = $xyzFRC{72}->[1];
#my $y5 = $xyzFRC{5}->[2];
#my $z67 = $xyzFRC{67}->[3];

#my $y1 = $xyzFRC{1}->[2];
#my $z119 = $xyzFRC{119}->[3];

#my $xg = ($x72 + $x77) /2.0;
#my $yg = ($y5 + $y1) /2.0;
#my $zg = ($z67 + $z119) /2.0;


my $x77 = $xyzFRC{71}->[1];
my $y77 = $xyzFRC{71}->[2];
my $z77 = $xyzFRC{71}->[3];

my $xg = $x77;
my $yg = $y77;
my $zg = $z77;


# Process nodes
#_-----------------
open IPNODE, "<$ntlcfile" or die "\033[31mError: Can't open file\033[0m ";

my $line = <IPNODE>;
while ($line) {
    if ($line =~ /Node number \[\s*\d+\]:\s*(\d+)/) {
	$nccn = $1;
	$nv = 1;
    }
    if ($line =~ /For version number (\d):/) {$nv = $1;}
    if ($line =~ /The Xj\((\d)\) coordinate is \[.*\]:\s*(.*)/){
	$i = $1;
	$xyzTLC{$nccn}->[$i] = $2;
    }    
    if ($line =~ /The derivative wrt direction 1 is \[.*\]:\s*(.*)/) {$derivTLC[$nccn][$nv][$i][1] = $1;}
    if ($line =~ /The derivative wrt direction 2 is \[.*\]:\s*(.*)/) {$derivTLC[$nccn][$nv][$i][2] = $1;}
    if ($line =~ /The derivative wrt directions 1 \& 2 is \[.*\]:\s*(.*)/) {$derivTLC[$nccn][$nv][$i][3] = $1;}
    if ($line =~ /The derivative wrt direction 3 is \[.*\]:\s*(.*)/) {$derivTLC[$nccn][$nv][$i][4] = $1;}
    if ($line =~ /The derivative wrt directions 1 \& 3 is \[.*\]:\s*(.*)/) {$derivTLC[$nccn][$nv][$i][5] = $1;}
    if ($line =~ /The derivative wrt directions 2 \& 3 is \[.*\]:\s*(.*)/) {$derivTLC[$nccn][$nv][$i][6] = $1;}
    if ($line =~ /The derivative wrt directions 1, 2 \& 3 is \[.*\]:\s*(.*)/) {$derivTLC[$nccn][$nv][$i][7] = $1;}
    $line = <IPNODE>;    
}
close IPNODE;

#########################

#my $dx77 = -$xyzTLC{77}->[1] + $xyzFRC{77}->[1];
#my $dy77 = -$xyzTLC{77}->[2] + $xyzFRC{77}->[2];
#my $dz77 = -$xyzTLC{77}->[3] + $xyzFRC{77}->[3];

#s03
#y $dx77 = -6;
#y $dy77 = -52;
#y $dz77 = -44;

#s02
#y $dx77 = 7;
#y $dy77 = -45;
#y $dz77 = 5;

#s01
#y $dx77 = 0;
#y $dy77 = 31
#y $dz77 = -45;

#s06
#y $dx77 = 0;
#y $dy77 = 7;
#y $dz77 = 5;

#s04
#y $dx77 = 9;
#y $dy77 = 18;
#y $dz77 = -37;



foreach my $ii (1..$ncnt){
 $i = $node[$ii];
 $xyzFRC{$i}->[1] = $xyzFRC{$i}->[1] - $xg;
 $xyzFRC{$i}->[2] = $xyzFRC{$i}->[2] - $yg;
 $xyzFRC{$i}->[3] = $xyzFRC{$i}->[3] - $zg;
}


my $x77 = $xyzTLC{71}->[1];
my $y77 = $xyzTLC{71}->[2];
my $z77 = $xyzTLC{71}->[3];


my $xgTLC = $x77;
my $ygTLC = $y77;
my $zgTLC = $z77;

foreach my $ii (1..$ncnt){
 $i = $node[$ii];
 $xyzTLC{$i}->[1] = $xyzTLC{$i}->[1] - $xgTLC ;
 $xyzTLC{$i}->[2] = $xyzTLC{$i}->[2] - $ygTLC;
 $xyzTLC{$i}->[3] = $xyzTLC{$i}->[3] - $zgTLC ;
}
##############################################################


    my $ipnodefile = 'FRCLeft_fittedmv.ipnode';
### Open ipnode file
    open IPNODE, ">$ipnodefile" or die "\033[31mError: Can't open ipnode file\033[0m ";

### Write ipnode header
    print IPNODE " CMISS Version 1.21 ipnode File Version 2\n";
    print IPNODE " Heading: \n\n";
    printf IPNODE " The number of nodes is [%5d]: %5d\n",$ncnt,$ncnt;
    printf IPNODE " Number of coordinates [%2d]: %2d\n",3,3;
    for (1..3){
        print IPNODE " Do you want prompting for different versions of nj=$_ [N]? Y\n";
    }
    for (1..3){
        print IPNODE " The number of derivatives for coordinate $_ is [0]: 7 \n";
    }
    my $nstart = 1;

    for my $n (1..$ncnt){
        my $nnd = $node[$n]; # original surface node number

        printf IPNODE "\n Node number [%5d]: %5d\n",$nnd,$nnd;
        for my $i (1..3){
            printf IPNODE " The number of versions for nj=$i is [1]: %2d \n",$versions[$nnd];
            for my $nv (1..$versions[$nnd]){
                if($versions[$nnd] > 1){
                    printf IPNODE " For version number $nv: \n";
                }

                if($i == 1) {printf IPNODE " The Xj(%1d) coordinate is [ 0.00000E+00]: %12.6f\n",$i,$xyzFRC{$nnd}->[1];}
                if($i == 2) {printf IPNODE " The Xj(%1d) coordinate is [ 0.00000E+00]: %12.6f\n",$i,$xyzFRC{$nnd}->[2];}
                if($i == 3) {printf IPNODE " The Xj(%1d) coordinate is [ 0.00000E+00]: %12.6f\n",$i,$xyzFRC{$nnd}->[3];}

                printf IPNODE " The derivative wrt direction 1 is [ 0.00000E+00]:      %12.6f\n",$derivFRC[$nnd][$nv][$i][1];
                printf IPNODE " The derivative wrt direction 2 is [ 0.00000E+00]:      %12.6f\n",$derivFRC[$nnd][$nv][$i][2];
                printf IPNODE " The derivative wrt directions 1 & 2 is [ 0.00000E+00]: %12.6f\n",$derivFRC[$nnd][$nv][$i][3];
                printf IPNODE " The derivative wrt direction 3 is [ 0.00000E+00]:      %12.6f\n",$derivFRC[$nnd][$nv][$i][4];
                printf IPNODE " The derivative wrt directions 1 & 3 is [ 0.00000E+00]: %12.6f\n",$derivFRC[$nnd][$nv][$i][5];
                printf IPNODE " The derivative wrt directions 2 & 3 is [ 0.00000E+00]: %12.6f\n",$derivFRC[$nnd][$nv][$i][6];
                printf IPNODE " The derivative wrt directions 1, 2 & 3 is [ 0.00000E+00]: %12.6f\n",$derivFRC[$nnd][$nv][$i][7];
            }
        } # $i
    } #nodes

    close IPNODE;
##############################################################


    my $ipnodefile = 'TLCLeft_fittedmv.ipnode';
### Open ipnode file
    open IPNODE, ">$ipnodefile" or die "\033[31mError: Can't open ipnode file\033[0m ";

### Write ipnode header
    print IPNODE " CMISS Version 1.21 ipnode File Version 2\n";
    print IPNODE " Heading: \n\n";
    printf IPNODE " The number of nodes is [%5d]: %5d\n",$ncnt,$ncnt;
    printf IPNODE " Number of coordinates [%2d]: %2d\n",3,3;
    for (1..3){
        print IPNODE " Do you want prompting for different versions of nj=$_ [N]? Y\n";
    }
    for (1..3){
        print IPNODE " The number of derivatives for coordinate $_ is [0]: 7 \n";
    }
    my $nstart = 1;

    for my $n (1..$ncnt){
        my $nnd = $node[$n]; # original surface node number

        printf IPNODE "\n Node number [%5d]: %5d\n",$nnd,$nnd;
        for my $i (1..3){
            printf IPNODE " The number of versions for nj=$i is [1]: %2d \n",$versions[$nnd];
            for my $nv (1..$versions[$nnd]){
                if($versions[$nnd] > 1){
                    printf IPNODE " For version number $nv: \n";
                }

                if($i == 1) {printf IPNODE " The Xj(%1d) coordinate is [ 0.00000E+00]: %12.6f\n",$i,$xyzTLC{$nnd}->[1];}
                if($i == 2) {printf IPNODE " The Xj(%1d) coordinate is [ 0.00000E+00]: %12.6f\n",$i,$xyzTLC{$nnd}->[2];}
                if($i == 3) {printf IPNODE " The Xj(%1d) coordinate is [ 0.00000E+00]: %12.6f\n",$i,$xyzTLC{$nnd}->[3];}

                printf IPNODE " The derivative wrt direction 1 is [ 0.00000E+00]:      %12.6f\n",$derivTLC[$nnd][$nv][$i][1];
                printf IPNODE " The derivative wrt direction 2 is [ 0.00000E+00]:      %12.6f\n",$derivTLC[$nnd][$nv][$i][2];
                printf IPNODE " The derivative wrt directions 1 & 2 is [ 0.00000E+00]: %12.6f\n",$derivTLC[$nnd][$nv][$i][3];
                printf IPNODE " The derivative wrt direction 3 is [ 0.00000E+00]:      %12.6f\n",$derivTLC[$nnd][$nv][$i][4];
                printf IPNODE " The derivative wrt directions 1 & 3 is [ 0.00000E+00]: %12.6f\n",$derivTLC[$nnd][$nv][$i][5];
                printf IPNODE " The derivative wrt directions 2 & 3 is [ 0.00000E+00]: %12.6f\n",$derivTLC[$nnd][$nv][$i][6];
                printf IPNODE " The derivative wrt directions 1, 2 & 3 is [ 0.00000E+00]: %12.6f\n",$derivTLC[$nnd][$nv][$i][7];
            }
        } # $i
    } #nodes

    close IPNODE;
##############################################################


open OPNODE, ">Displacement.ipfiel" or die "\033[31mError: Can't open file\033[0m ";



 print OPNODE " CMISS Version 2.1  ipfiel File Version 3\n";
 print OPNODE " Heading: fitted;\n";
 print OPNODE "\n";
 print OPNODE " The number of field variables is [3]: 16\n";
 print OPNODE " The number of nodes is [    40]:     47\n";
 print OPNODE " Do you want prompting for different versions of field variable 1 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 2 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 3 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 4 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 5 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 6 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 7 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 8 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 9 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 10 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 11 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 12 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 13 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 14 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 15 [N]? Y\n";
 print OPNODE " Do you want prompting for different versions of field variable 16 [N]? Y\n";
 print OPNODE " The number of derivatives for field variable 1 is [0]: 7\n";
 print OPNODE " The number of derivatives for field variable 2 is [0]: 7\n";
 print OPNODE " The number of derivatives for field variable 3 is [0]: 7\n";
 print OPNODE " The number of derivatives for field variable 4 is [0]: 7\n";
 print OPNODE " The number of derivatives for field variable 5 is [0]: 7\n";
 print OPNODE " The number of derivatives for field variable 6 is [0]: 7\n";
 print OPNODE " The number of derivatives for field variable 7 is [0]: 7\n";
 print OPNODE " The number of derivatives for field variable 8 is [0]: 7\n";
 print OPNODE " The number of derivatives for field variable 9 is [0]: 7\n";
 print OPNODE " The number of derivatives for field variable 10 is [0]:  7\n";
 print OPNODE " The number of derivatives for field variable 11 is [0]:  7\n";
 print OPNODE " The number of derivatives for field variable 12 is [0]:  7\n";
 print OPNODE " The number of derivatives for field variable 13 is [0]:  7\n";
 print OPNODE " The number of derivatives for field variable 14 is [0]:  7\n";
 print OPNODE " The number of derivatives for field variable 15 is [0]:  7\n";
 print OPNODE " The number of derivatives for field variable 16 is [0]:  7\n";

  foreach my $ii (1..$ncnt){
 
  $i = $node[$ii]; 

  print OPNODE "\n Node number [$i]: $i\n";

  for my $ifiel (1..16) {

  if($ifiel == 5) {
  ###################
         print OPNODE " The number of versions for field variable $ifiel is [1]: $versions[$i]\n";
		for my $nv (1..$versions[$i]) {
		print OPNODE " For version number $nv: \n";

                my $x11 = -$xyzFRC{$i}->[1] + $xyzTLC{$i}->[1];
                my $xd1 = -$derivFRC[$i][$nv][1][1]+$derivTLC[$i][$nv][1][1];
                my $xd2 = -$derivFRC[$i][$nv][1][2]+$derivTLC[$i][$nv][1][2];
                my $xd3 = -$derivFRC[$i][$nv][1][3]+$derivTLC[$i][$nv][1][3];
                my $xd4 = -$derivFRC[$i][$nv][1][4]+$derivTLC[$i][$nv][1][4];
                my $xd5 = -$derivFRC[$i][$nv][1][5]+$derivTLC[$i][$nv][1][5];
                my $xd6 = -$derivFRC[$i][$nv][1][6]+$derivTLC[$i][$nv][1][6];
                my $xd7 = -$derivFRC[$i][$nv][1][7]+$derivTLC[$i][$nv][1][7];
		print OPNODE " The field variable $ifiel value is [ 0.00000E+00]:   $x11\n"; 
		print OPNODE " The derivative wrt direction 1 is [ 0.00000E+00]: $xd1\n";
		print OPNODE " The derivative wrt direction 2 is [ 0.00000E+00]: $xd2\n";
		print OPNODE " The derivative wrt directions 1 & 2 is [ 0.00000E+00]: $xd3\n";
		print OPNODE " The derivative wrt direction 3 is [ 0.00000E+00]: $xd4\n";
		print OPNODE " The derivative wrt directions 1 & 3 is [ 0.00000E+00]: $xd5\n";
		print OPNODE " The derivative wrt directions 2 & 3 is [ 0.00000E+00]: $xd6\n";
		print OPNODE " The derivative wrt directions 1, 2 & 3 is [ 0.00000E+00]: $xd7\n";
		    
		} #for nv
   ###################
    } elsif ($ifiel == 6) {
  #######################
		print OPNODE " The number of versions for field variable $ifiel is [1]: $versions[$i]\n";
		for my $nv (1..$versions[$i]) {
		  print OPNODE " For version number $nv: \n";
                my $x11 = -$xyzFRC{$i}->[2] + $xyzTLC{$i}->[2];
                my $xd1 = -$derivFRC[$i][$nv][2][1]+$derivTLC[$i][$nv][2][1];
                my $xd2 = -$derivFRC[$i][$nv][2][2]+$derivTLC[$i][$nv][2][2];
                my $xd3 = -$derivFRC[$i][$nv][2][3]+$derivTLC[$i][$nv][2][3];
                my $xd4 = -$derivFRC[$i][$nv][2][4]+$derivTLC[$i][$nv][2][4];
                my $xd5 = -$derivFRC[$i][$nv][2][5]+$derivTLC[$i][$nv][2][5];
                my $xd6 = -$derivFRC[$i][$nv][2][6]+$derivTLC[$i][$nv][2][6];
                my $xd7 = -$derivFRC[$i][$nv][2][7]+$derivTLC[$i][$nv][2][7];
		print OPNODE " The field variable $ifiel value is [ 0.00000E+00]:   $x11\n"; 
		print OPNODE " The derivative wrt direction 1 is [ 0.00000E+00]: $xd1\n";
		print OPNODE " The derivative wrt direction 2 is [ 0.00000E+00]: $xd2\n";
		print OPNODE " The derivative wrt directions 1 & 2 is [ 0.00000E+00]: $xd3\n";
		print OPNODE " The derivative wrt direction 3 is [ 0.00000E+00]: $xd4\n";
		print OPNODE " The derivative wrt directions 1 & 3 is [ 0.00000E+00]: $xd5\n";
		print OPNODE " The derivative wrt directions 2 & 3 is [ 0.00000E+00]: $xd6\n";
		print OPNODE " The derivative wrt directions 1, 2 & 3 is [ 0.00000E+00]: $xd7\n";
		    
		} #for nv
   ###################
    } elsif ($ifiel == 7) {
   ###################
		print OPNODE " The number of versions for field variable $ifiel is [1]: $versions[$i]\n";
		for my $nv (1..$versions[$i]) {
		print OPNODE " For version number $nv: \n";
                my $x11 = -$xyzFRC{$i}->[3] + $xyzTLC{$i}->[3];
                my $xd1 = -$derivFRC[$i][$nv][3][1]+$derivTLC[$i][$nv][3][1];
                my $xd2 = -$derivFRC[$i][$nv][3][2]+$derivTLC[$i][$nv][3][2];
                my $xd3 = -$derivFRC[$i][$nv][3][3]+$derivTLC[$i][$nv][3][3];
                my $xd4 = -$derivFRC[$i][$nv][3][4]+$derivTLC[$i][$nv][3][4];
                my $xd5 = -$derivFRC[$i][$nv][3][5]+$derivTLC[$i][$nv][3][5];
                my $xd6 = -$derivFRC[$i][$nv][3][6]+$derivTLC[$i][$nv][3][6];
                my $xd7 = -$derivFRC[$i][$nv][3][7]+$derivTLC[$i][$nv][3][7];
		print OPNODE " The field variable $ifiel value is [ 0.00000E+00]:   $x11\n"; 
		print OPNODE " The derivative wrt direction 1 is [ 0.00000E+00]: $xd1\n";
		print OPNODE " The derivative wrt direction 2 is [ 0.00000E+00]: $xd2\n";
		print OPNODE " The derivative wrt directions 1 & 2 is [ 0.00000E+00]: $xd3\n";
		print OPNODE " The derivative wrt direction 3 is [ 0.00000E+00]: $xd4\n";
		print OPNODE " The derivative wrt directions 1 & 3 is [ 0.00000E+00]: $xd5\n";
		print OPNODE " The derivative wrt directions 2 & 3 is [ 0.00000E+00]: $xd6\n";
		print OPNODE " The derivative wrt directions 1, 2 & 3 is [ 0.00000E+00]: $xd7\n";
		    
		} #for nv
  #################
    } else {
   ###################
		print OPNODE " The number of versions for field variable $ifiel is [1]: $versions[$i]\n";
		for my $nv (1..$versions[$i]) {
		    print OPNODE " For version number $nv: \n";
		    print OPNODE " The field variable $ifiel value is [ 0.00000E+00]: 0.000000\n"; 
		    print OPNODE " The derivative wrt direction 1 is [ 0.00000E+00]: 0.00000000\n";
		    print OPNODE " The derivative wrt direction 2 is [ 0.00000E+00]: 0.00000000\n";
		    print OPNODE " The derivative wrt directions 1 & 2 is [ 0.00000E+00]: 0.00000000\n";
		    print OPNODE " The derivative wrt direction 3 is [ 0.00000E+00]: 0.00000000\n";
		    print OPNODE " The derivative wrt directions 1 & 3 is [ 0.00000E+00]: 0.00000000\n";
		    print OPNODE " The derivative wrt directions 2 & 3 is [ 0.00000E+00]: 0.00000000\n";
		    print OPNODE " The derivative wrt directions 1, 2 & 3 is [ 0.00000E+00]: 0.00000000\n";
		    
		} #for nv
  ###################
  }  #ipfiel
  ###################

}
}


#####################################################
#####################################################

close OPNODE;


#####################################################
#####################################################
