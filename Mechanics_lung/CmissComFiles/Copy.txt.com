
set echo on;

##set up size of arrays (ippara) and coordinates (ipcoor)
#-------------------------------------------

fem def para;r;CmissBasicFiles/GeneralMechanics reg all;
fem def coor;r;CmissBasicFiles/CollapseVolume reg all;

#read in bases
#----------------
fem def base;r;$root/UniversalFiles/Bases/TriCubic_Vol reg all;
fem def;add base;r;$root/UniversalFiles/Bases/BiCubic_Surface reg all;
fem def;add base;r;CmissBasicFiles/Pressure reg all;

#set up error and number of iterations
#------------------------------------
$error = 1e-6;
$iterate = 40;

#define field numbers
#-------------------
$P  = 1; # pressure
$x0 = 2; # reference x
$y0 = 3; # reference y
$z0 = 4; # reference z

$dx = 5; # displacement x
$dy = 6; # displacement y
$dz = 7; # displacement z


#read in info about particular subject
#--------------------------------------
$subject_name=`python $root/UniversalFiles/read_props.py $root $study $subject Name`;
$status = $?;
chomp($subject_name);
if($subject_name eq ""){
	print "ERROR: Check your subject is set up in SubjectInfo.csv\n";
	print "Looking for $subject, study $study \n";
	fem quit;
}
if ($posture eq 'Upright'){
    $volume = `python $root/UniversalFiles/read_props.py $root $study $subject UpFRC_SupFRC`; #upright FRC from PFTs
}else {
    $volume = 100;
}
$densityFRC= `python $root/UniversalFiles/read_props.py $root $study $subject rhoREF`;
$status = $?;
chomp($densityFRC);

$ref_vol_calc=`python $root/UniversalFiles/read_props.py $root $study $subject UpFRC_SupFRC`;
$status = $?;
chomp($ref_vol_calc);

$posP=0;#Initialise posP used in Output intital
@scale_steps = ($volume);



#reference volume is 0.5*upright FRC whise volume is $ref_vol_calc
#------------------------------------------------------------------

if ($protocol eq 'Supine'){
$mult = 0.5;
} 
if ($protocol eq 'Prone'){
$mult = 0.5;
} 


if ($protocol eq 'FRC'){
$mult = 0.5;
} 
if ($protocol eq 'TLC'){
$mult = 0.25;
}

if ($subject_name eq 'Subject06'){
if ($protocol eq 'Supine'){
$densityFRC = 0.216 * 1.e-03;}
if ($protocol eq 'Prone'){
$densityFRC = 0.257 * 1.e-03;}
}

if ($subject_name eq 'Subject04'){
if ($protocol eq 'Supine'){
$densityFRC = 0.21 * 1.e-03;}
if ($protocol eq 'Prone'){
$densityFRC = 0.206 * 1.e-03;}
}

if ($subject_name eq 'Subject03'){
if ($protocol eq 'Supine'){
$densityFRC = 0.254 * 1.e-03;}
if ($protocol eq 'Prone'){
$densityFRC = 0.247 * 1.e-03;}
}

if ($subject_name eq 'Subject02'){
if ($protocol eq 'Supine'){
$densityFRC = 0.246 * 1.e-03;}
if ($protocol eq 'Prone'){
$densityFRC = 0.3 * 1.e-03;}
}

if ($subject_name eq 'Subject01'){
if ($protocol eq 'Supine'){
$densityFRC = 0.236 * 1.e-03;}
if ($protocol eq 'Prone'){
$densityFRC = 0.25 * 1.e-03;}
}



$ref_pct = $mult * $ref_vol_calc; #percentage of supine between FRC and TLC


$ref_pct = 0.5 * $ref_vol_calc; #percentage of supine between FRC and TLC


$density = $densityFRC/($ref_pct/100);#density ar reference volume calculated from FRC density

print "Ratio = $ref_vol_calc\n";
print "density = $density\n";


$scale_0 = ($ref_pct/100)**(1/3); #same for TLC and FRC scaling applied to lung

$init_path = $root.'/Data/'.$study.'/'.$subject_name.'/'.$protocol.'/Mechanics';
$geometry_path = $root.'/GeometricModels/FittingLungs/FilesSurfaceLungs';
$grav_path =$init_path;

$initialfile = $lung.$volume;
$output = $posture.$lung;
$Model = $root.'/Data/'.$study.'/'.$subject_name.'/'.$protocol.'/Lung/FEMesh';

#Read in Geometry
#################
read com;CmissComFiles/SetGeometry;


