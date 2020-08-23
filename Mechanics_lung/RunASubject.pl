
$cmiss_root=$ENV{CMISS_EXECUTABLE};
$cmgui_root=$ENV{CMGUI_2_6_2}; #Where is your cmgui?
$root=$ENV{LUNG_ROOT};

my $study = $ARGV[0];
my $subject = $ARGV[1];
my $lung    = $ARGV[2];
my $posture = $ARGV[3];
my $protocol= $ARGV[4];
my $options = $ARGV[5];
my $v_t = 0;
$v_t = $ARGV[6]; #for an optional tidal volume %

my $comfile = 'CmissComFiles/SpecifyProblem.com';


if($study =~/HLA/){$study = 'Human_Lung_Atlas';}
if($study =~/HPE/){$study = 'Human_PE_Study_HRC';}


##### LUNGS #####
my (@lungs);
if($lung =~ /both/){
    $lungs[0] = 'Left';
    $lungs[1] = 'Right';
}else{
    $lungs[0] = $lung;
}

if($protocol eq ''){
$protocol='FRC';
}
##### POSTURE #####
my (@postures);
if($posture =~ /all/){
    $postures[0] = 'Supine';
    $postures[1] = 'Prone';
    $postures[1] = 'Upright';
}else{
    $postures[0] = $posture;
}

##### REFINEMENT #####
my $refined = '';
if($options =~ /zeroGinput/){
    $refined='zeroG';
}elsif($options =~ /refined/){
    $refined = 'refined';
    print "OPtion not currently implemented \n";
    die;
}else{
    $refined = 'coarse';
}
##YOUR CMISS AND CMGUI EXECUTABLES##


foreach my $lung (@lungs){
    foreach my $posture (@postures){
	open(OPCOM, ">$comfile") or die "Can't open comfile\n";
	print OPCOM " \$root = \'$root\';\n";
	print OPCOM " \$study = \'$study\';\n";	
	print OPCOM " \$subject = \'$subject\';\n";
	print OPCOM " \$protocol = \'$protocol\';\n";
	print OPCOM " \$posture = \'$posture\';\n";
	print OPCOM " \$lung = \'$lung\';\n";
	print OPCOM " \$refined = \'$refined\';\n";
	print OPCOM " \$v_t  = \'$v_t\';\n";
	close OPCOM;

	print "Run cm for $subject, $lung, $posture, additional% volume= $v_t \n";

        system "$cmiss_root CmissComFiles/RunExpansion_Uniform.com";
#       system "$cmiss_root CmissComFiles/RunGravity.com";
    } #postures
} #lungs


