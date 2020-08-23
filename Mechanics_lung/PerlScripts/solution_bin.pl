#!/usr/bin/perl

#This file finds all solution values within certain bin intervals of z height.


use strict;

my ($exnode, $exnodefile);
my ($bin, $zmin, $zmax, $line, $num_intervals, $i, $j);
my @value;
my (@z, @P, @R); 
#stores z coord, pressure, radius, velocity values for each node.
my ($node_num, $np_min, $np_max, $total_nodes);
my (@bin_num, @bin_P, @bin_R);
my (@sd_num, @sd_P, @sd_R);
my (@cv_num, @cv_P, @cv_R);
my ($Z1, $Z2, $np, @npnode, $output, $output_stat, @z_mid, $nodes_found, $PI);
my ($AREA);
my ($direction);
my ($total_P, $total_R, $total_P_SD, $total_R_SD);
my ($total_P_CV, $total_R_CV);

$exnode = $ARGV[0];
$direction = $ARGV[1];
$bin = $ARGV[2];
my $rho0 = $ARGV[3] * 1000; #convert g.mm^-3 to g.cm^-3
my $rhoFRC = $ARGV[4]; #density at FRC

#$exnodefile = "$exnode.ipdata";
$exnodefile = "$exnode.exdata";

open EXNODE, "<$exnodefile" or die "\033[31mError: Can't open $exnodefile file\033[0m ";

$PI = 3.141592654;

#This first loop to find the maximum and minimum z heights, 
#and store nodal co-ordinates in an array:

$zmax = -1000000;
$zmin = 1000000;
$total_nodes = 0; #node counter

$line = <EXNODE>;
$line = <EXNODE>;
$node_num = 0;
while ($line) {
    if($line =~ /Node:/) {
	$node_num++;
	$line = <EXNODE>;
    }

    if($node_num > 0){
      if($line =~ /\s+(\S*)\s+(\S*)\s+(\S*)/){
	  @value = ( $1, $2, $3);

	  $total_nodes = $total_nodes + 1;
	  $npnode[$total_nodes] = $node_num;
  	  if ($direction eq "z") {
	      $z[$node_num] = $value[2]; #z coord
	  } elsif ($direction eq "y") {
	      $z[$node_num] = $value[1]; #y coord
	  } elsif ($direction eq "x") {
	      $z[$node_num] = $value[0]; #x coord
	  }

	  $line = <EXNODE>;
          if($line =~ /\s+(\S*)\s+(\S*)/){
  	    @value = ( $1, $2);
          }
	  if($value[1] < 1 ){
	      $value[1] = 1;
	      $value[0] = 0;
	  }

	  $P[$node_num] = $value[0]/98.0665; #pressure in cmH2O
	  $R[$node_num] = $rho0/$value[1];
	
	  if ($z[$node_num] < $zmin) {
	      $zmin = $z[$node_num];
	      $np_min = $node_num;
	  }
	  if ($z[$node_num] > $zmax) {
	      $zmax = $z[$node_num];
	      $np_max = $node_num;
	  }
      }
    }
    $line = <EXNODE>;

}

close EXNODE;

$output = "$exnode.out.$direction.$bin";
my $opdata = $exnode.'data'.$direction;
open OUTPUT, ">$output" or die "\033[31mError: Can't open $output file\033[0m ";
open OPDATAFILE, ">$opdata" or die "\033[31mError: Can't open op_data file\033[0m ";

$num_intervals = ($zmax - $zmin) / $bin; #number of bin intervals
#initialise arrays
for ($j=1;$j<=$num_intervals;$j++){
#mean
    $bin_num[$j] = 0;
    $bin_P[$j] = 0;
    $bin_R[$j] = 0;
#sd
    $sd_num[$j] = 0;
    $sd_P[$j] = 0;
    $sd_R[$j] = 0;
#cv
    $cv_num[$j] = 0;
    $cv_P[$j] = 0;
    $cv_R[$j] = 0;
}

#find all data values in any bin interval & sum values
my $meanheight;
for($i=1;$i<=$total_nodes;$i++){
    $np = $npnode[$i];
    $total_P = $total_P + $P[$np]; #to find total mean, SD, CV for whole data set
    $total_R = $total_R + $R[$np];
    $meanheight = $meanheight + 100*($z[$np]-$zmin)/($zmax-$zmin);
    for ($j=1;$j<=$num_intervals+1;$j++){  #$num_intervals+1 to round up!
	$Z1 = $zmin + ($j-1) * $bin;
	$Z2 = $zmin + $j * $bin;
	if ($j > $num_intervals) {
	    $Z2 = $zmax; #set to max so don't go past lung height
	}
	$z_mid[$j] = ($Z1 + $Z2)/2; #mid point of bin interval
	if($j < $num_intervals) {
	    if (($z[$np] >= $Z1) && ($z[$np] < $Z2)) {
		$bin_num[$j] = $bin_num[$j] + 1;
		#print "number in bin ($j) $bin_num[$j]\n";
		$bin_P[$j] = $bin_P[$j] + $P[$np]; #pressure
		$bin_R[$j] = $bin_R[$j] + $R[$np]; #radius
	    }
	} else {
	    if (($z[$np] > $Z1) && ($z[$np] <= $Z2)) {
		$bin_num[$j] = $bin_num[$j] + 1;
		$bin_P[$j] = $bin_P[$j] + $P[$np];
		$bin_R[$j] = $bin_R[$j] + $R[$np];
	    } 
	}
    }
}

#Now divide result values by the number of data points in each bin interval
$total_P = $total_P / $total_nodes; #to find total mean, SD, CV for whole data set
$total_R = $total_R / $total_nodes; #mean of densities
$meanheight = $meanheight/$total_nodes; #mean of % heights

#print "Overall averages: P=$total_P, R=$total_R\n";
    
$nodes_found = 0;

for ($j=1;$j<=$num_intervals+1;$j++){
    $nodes_found = $nodes_found + $bin_num[$j];
    if ($bin_num[$j] != 0) {
	$bin_P[$j] = $bin_P[$j] / $bin_num[$j]; #average value in bin
	$bin_R[$j] = $bin_R[$j] / $bin_num[$j];
    }
}

#Now also want to calculate the standard deviation and coefficient of variation of the data in a slice:
#Have to first loop through all of the nodes again:
my ($rsq, $rsq1, $rsq2, $rsq3);

for($i=1;$i<=$total_nodes;$i++){
    $np = $npnode[$i];
    $total_P_SD = $total_P_SD + ($P[$np]-$total_P)**2; #total SDs for whole data set
    $total_R_SD = $total_R_SD + ($R[$np]-$total_R)**2;
    my $pcth = 100*($z[$np]-$zmin)/($zmax-$zmin);
    print OPDATAFILE "$pcth $P[$np] $R[$np]\n";
    $rsq1 = $rsq1 + ($pcth-$meanheight)*($R[$np]-$total_R);
    $rsq2 = $rsq2 + ($pcth - $meanheight)**2;
    $rsq3 = $rsq3 + ($R[$np] - $total_R)**2; 
    for ($j=1;$j<=$num_intervals+1;$j++){  #$num_intervals+1 to round up!
	$Z1 = $zmin + ($j-1) * $bin;
	$Z2 = $zmin + $j * $bin;
	$z_mid[$j] = ($Z1 + $Z2)/2; #mid point of bin interval
	if($j < $num_intervals) {
	    if (($z[$np] >= $Z1) && ($z[$np] < $Z2)) {
		$sd_num[$j] = $sd_num[$j] + 1;
		$sd_P[$j] = $sd_P[$j] + ($P[$np]-$bin_P[$j])**2; #pressure
		$sd_R[$j] = $sd_R[$j] + ($R[$np]-$bin_R[$j])**2; #radius
	    }
	} else {
	    if (($z[$np] > $Z1) && ($z[$np] <= $Z2)) {
		$sd_num[$j] = $sd_num[$j] + 1;
		$sd_P[$j] = $sd_P[$j] + ($P[$np]-$bin_P[$j])**2;
		$sd_R[$j] = $sd_R[$j] + ($R[$np]-$bin_R[$j])**2;
	    } 
	}
    }
}
close OPDATAFILE;

my $slope = $rsq1/$rsq2;
$rsq = $rsq1/($rsq2 * $rsq3)**0.5;

$total_P_SD = ($total_P_SD / ($total_nodes-1))**0.5; #total SDs for whole data set
$total_R_SD = ($total_R_SD / ($total_nodes-1))**0.5;
printf "Density = %7.4f +-%7.4f [target%7.4f]\n",$total_R,$total_R_SD,$rhoFRC;
printf "Slope all points = %8.5f, R2 = %4.2f\n", $slope, $rsq;

my $IntIntervals;
for ($j=1;$j<=$num_intervals+1;$j++){
    if ($sd_num[$j] > 1) {
	$sd_P[$j] = ($sd_P[$j]/($sd_num[$j]-1))**0.5;
	$sd_R[$j] = ($sd_R[$j]/($sd_num[$j]-1))**0.5;
    }
    $IntIntervals++;
}
#overall values
$total_P_CV=$total_P_SD / $total_P;
$total_R_CV=$total_R_SD / $total_R;

my ($rsq, $rsq1, $rsq2, $rsq3);

print OUTPUT "$output\n";
for ($j=1;$j<=$num_intervals+1;$j++){
    if ($bin_num[$j] != 0) {
#	my $pcnt_height = 100 * ($z_mid[$j] - $zmin)/($zmax-$zmin);
	my $pcnt_height = 100*(0.5-1+$j)/(1+$IntIntervals-1);

	printf OUTPUT "  %4d %5d %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\n",$j,$bin_num[$j],$z_mid[$j],$pcnt_height,$bin_P[$j],$bin_R[$j],$sd_P[$j],$sd_R[$j];
	$rsq1 = $rsq1 + ($pcnt_height-$meanheight)*($bin_R[$j]-$total_R);
	$rsq2 = $rsq2 + ($pcnt_height - $meanheight)**2;
	$rsq3 = $rsq3 + ($bin_R[$j] - $total_R)**2; 
    }
}
print OUTPUT " \n";

if ($nodes_found != $total_nodes) {
    print "!Warning: only $nodes_found found, out of total of $total_nodes nodes!\n";
}
my $slope = $rsq1/$rsq2;
$rsq = $rsq1/($rsq2 * $rsq3)**0.5;
printf "Slope mean points = %8.5f, R2 = %4.2f\n", $slope, $rsq;

close OUTPUT;
