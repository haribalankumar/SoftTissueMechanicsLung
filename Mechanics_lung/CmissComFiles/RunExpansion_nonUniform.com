
$posP = 0;
read com;CmissComFiles/SpecifyProblem; #specify the subject, lung
fem read com;CmissComFiles/BasicSetup;

##DEFINE THE GRAVITY VECTORS FOR SPECIFIC POSTURES
$gvect{"Supine"}  = [ 0, -9810, 0 ];
$gvect{"Prone"}   = [ 0,  9810, 0 ];
$gvect{"Upright"} = [ 0,  0, 0 ];

#PARAMETERS FOR SETTING STEP SIZE AND STIFFNESS
$Gnsteps = 5; #number of gravity load increments
$increment = 1/$Gnsteps;  #size of increment

read com;CmissComFiles/GroupLungNonuniform; #groupings

fem list elem group;
fem list node group;
#em list face group;


fem def data;c from_node node outer_nodes; #calculates data points and Xi coords
fem def data;w;WorkingFiles/LungSurfacePoints geometry;
fem def xi;w;WorkingFiles/LungSurfacePoints coupled_nodes;


fem read com;CmissComFiles/ScaleLungToReference;

# define fields
#####em def field;r;InitialConditions/InitialMahyarMesh;
#####em def elem;r;InitialConditions/InitialMahyarMesh field;
fem def field;r;InitialConditions/Left_Initialize16Field;
fem def elem;r;InitialConditions/Left_InitialElem16Field field;


fem def field;w;${init_path}/test00

# read the dispacment field 
#---------------------------
fem def field;r;$Model/displacement
fem def field;w;${init_path}/test0

# FIBRES (DEFAULT FIELDS)
fem def fibr;d;
fem def elem;d fibre;

fem update node deriv 1 versions individual;
fem update node deriv 2 versions individual;
fem update node deriv 3 versions individual;
fem update node scale_factor;


fem def equa;r;CmissBasicFiles/Compressible;
fem def mate;r;CmissBasicFiles/SEDF;
fem update material density $density;


# FIT ALVEOLAR PRESSURES
fem def fit;r;CmissBasicFiles/Pressure field;


$Uniform='GravitySoln';
fem def init;r;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;
fem def solve;r;CmissBasicFiles/GMRES;


if ($surfacetype eq 'smooth'){
  fem def mapping;r;CmissBasicFiles/LungMappingSmoothEdges;
} else {
  fem def mapping;r;CmissBasicFiles/LungMappingSharpEdges;
}


fem evaluate pressure gauss;
fem solve increment 1 iterate $iterate error $error;


fem export node;${init_path}/GSolve as cube field;
fem def init;w;${init_path}.'/ZeroG_Uniform'.$lung.'_'.$volume;


# INITIAL CONDITIONS SET FIXED DISPLACEMENTS AND FORCES

$ipfile = ${init_path}.'/ZeroG_Uniform'.$lung.'_'.$volume.'.ipinit'; #initial geometry and forces
$opfile = ${init_path}.'/'.${initialfile}.'.ipinit';
$opfile2 =${init_path}.'/'.${initialfile}.'_NOFIX.ipinit';

CORE::open(IPFILE, "<$ipfile") or die "\033[31mError11: Can't open input file $ipfile \033[0m \n";
CORE::open(OPFILE, ">$opfile2") or die "\033[31mError11: Can't open opfile2\033[0m \n";
$line = <IPFILE>;
$print = 0;
while ($line){
    if ($line =~ / Dependent variable initial conditions:/){$print = 1;}
    if ($line =~ / Specify the gravity vector components /){$print = 2;}
    if ($print == 1){ print OPFILE "$line"; }
    if ($print == 2){
	print OPFILE " Specify the gravity vector components [0,0,0]: $gvect{$posture}->[0] $gvect{$posture}->[1] $gvect{$posture}->[2]\n";
    }
    $line = <IPFILE>;
} #while
CORE::close IPFILE;
CORE::close OPFILE;

#headerfile = 'Intermediate/Header'.'.ipinit';
##system "cat $headerfile $opfile > temp.file";
##system "mv temp.file $opfile";

if ($surfacetype eq 'smooth'){
$headerfile = "Intermediate/HeaderUniform_Smooth.ipinit";
} else {
$headerfile = "Intermediate/HeaderUniform_Sharp.ipinit";
}

###headerfile = 'Intermediate/Header'.'.ipinit';
###sssystem "cat $headerfile $opfile > temp.file";
#s##ssystem "mv temp.file $opfile";

CORE::open(IPFILE, "<$headerfile") or die "\033[31mError11: Can't open input file $headerfile \033[0m \n";
CORE::open(OPFILE, ">$opfile") or die "\033[31mError11: Can't open opfile\033[0m \n";
       $line = <IPFILE>;
       while ($line){
               print OPFILE "$line";
               $line = <IPFILE>;
       }
CORE::close IPFILE;
CORE::open(IPFILE, "<$opfile2") or die "\033[31mError11: Can't open input file $opfile2 \033[0m \n";
       $line = <IPFILE>;
       while ($line){
               print OPFILE "$line";
               $line = <IPFILE>;
       }
CORE::close IPFILE;
CORE::close OPFILE;

fem def init;w;${init_path}.${initialfile};
$temporaryvar=${init_path}.${initialfile};
print "Read initial from $temporaryvar \n";

fem def init;r;${init_path}.${initialfile};
######################################################################################
# STORE THE CURRENT GEOMETRY (ZERO GRAVITY) IN FIELDS. USE AS PLEURAL SURFACE
for my $j (1..3){
    $njj[$j] = 7 + $j;
    $njs[$j] = 10 + $j;
    fem update field $njj[$j] substitute solution niy 1 depvar $j;
    fem update field $njs[$j] substitute solution niy 1 depvar $j;
}

#############################################################################################

# STORE THE REFERENCE GEOMETRY IN FIELDS
$posP = 0;
fem update field $P substitute constant $posP; # initial pressure field

fem def mate;r;CmissBasicFiles/SEDF;
fem update material density $density;

###############################################################
# PROBLEM SOLUTION
fem def solve;r;CmissBasicFiles/GMRES;

fem update field $x0 nodes substitute solution niy 1 depvar 1 force;
fem update field $y0 nodes substitute solution niy 1 depvar 2 force;
fem update field $z0 nodes substitute solution niy 1 depvar 3 force;

# READ IN LOCATIONS OF NODES ON LUNG SURFACE IN THE REFERENCE STATE
fem def data;r;WorkingFiles/LungSurfacePoints coupled_nodes;
fem def xi;r;WorkingFiles/LungSurfacePoints coupled_nodes;
fem def xi;w;WorkingFiles/LungSurfacePoints coupled_nodes;

##########################################################################

######
## HARI COMMENTED - Why this solve/?
##fem evaluate pressure gauss; #updates ratio deformed:undeformed
##fem solve increment 1 iterate $iterate error $error;

# HARI COMMENTED
####em evaluate pressure gauss;

fem export node;${init_path}/AfterFirstSolve as cube field; #debug. Does not converge here.
 fem list elem total deformed;

$sum_increment = $increment;
$gravity = 0;

$TLC2FRC_Ratio=2.35;    # this value designed for uniform expansion 
$scaling_ratio=($TLC2FRC_Ratio)**(1/3);
$cavity_scale=($scaling_ratio)**($increment);

print " cavity Scale is $cavity_scale\n"

$increment = $increment/1;

$i = 0;
for ($j = 1; $j <= $Gnsteps; $j++){
    print "Solution step $j of $Gnsteps for $subject $lung $posture\n";

    # Step one uniform expansion 
    fem update field $njs[1] nodes all_nodes add field 5 scale $increment;
    fem update field $njs[2] nodes all_nodes add field 6 scale $increment;
    fem update field $njs[3] nodes all_nodes add field 7 scale $increment;

    fem def field;w;${init_path}/test2
    fem def equa;r;CmissBasicFiles/Compressible;
    fem def mate;r;CmissBasicFiles/SEDF;
    fem update material density $density;

     if ($surfacetype eq 'smooth'){
     fem def mapping;r;CmissBasicFiles/LungMappingSmoothEdges;
     } else {
     fem def mapping;r;CmissBasicFiles/LungMappingSharpEdges;
     }

    fem def solve;r;CmissBasicFiles/GMRES;
    fem update field $P substitute constant $posP;
    fem export node;${init_path}/NonuniStep1 as cube field; #debug
    fem export elem;${init_path}/NonuniStep1 as cube field; #debug
    print "scale cavity by $cavity_scale to $step % of TLC\n";
    
    #..CHANGE THE SIZE OF THE LUNG TO MATCH THE CAVITY (update solution)
    read com;CmissComFiles/ChangeLungMatchCavity;
    
    fem export node;${init_path}/NonUniStep2_$j as cube field; #debug
    fem export elem;${init_path}/NonUniStep2_$j as cube field; #debug
    

#   fem list elem total;
#   print '.';
#   fem list elem total deformed;
#   print '.';

##########
##########
    read com;CmissComFiles/OutputInitialNonuniform;

#..EXPORT THE RESULTS
    $i++;
#..CALCULATE THE PRESSURES NEAR THE SURFACE

    #..MODIFY THE INITIAL FORCES TO MAINTAIN THE GEOMETRY
    read com;CmissComFiles/ModifyInitial;

    fem export node;${init_path}/NonuniStep3_$j as cube field; #debug
    fem export elem;${init_path}/NonuniStep3_$j as cube field; #debug
    

################################################################################################
#################### Project to the Correct pleular cavity######################################
    read com;CmissComFiles/ProjectNormalNonuniform;      
#   read com;CmissComFiles/ProjectNormaltest;      

#    if ($surfacetype eq 'smooth'){
#      read com;CmissComFiles/ProjectNormal_SmoothEdges;
#    } else {
#      read com;CmissComFiles/ProjectNormal_SharpEdges;
#    }



    fem export node;${init_path}/NonuniStep4_$j as cube field; #debug
    fem export elem;${init_path}/NonuniStep4_$j as cube field; #debug
################################################################################################
	
    $i++;

    print "--------------------------------------------------------\n";
    print " Solve incr TO compute Surface Reaction forces$j \n";
    print "--------------------------------------------------------\n";

#############
#############
    read com;CmissComFiles/OutputInitialNonuniform;

    fem export node;${init_path}/NonuniStep5_$j as cube field; #debug
    fem export elem;${init_path}/NonuniStep5_$j as cube field; #debug


    read com;CmissComFiles/ModifyInitial;
    fem def init;w;SurfaceForce$j;
####################################################################################
    print "Solution step $j of $Gnsteps for $subject $lung $posture\n";

# HARI COMMENTED BELOW: not needed here
#   fem def solve;r;CmissBasicFiles/GMRES;

#    if ($surfacetype eq 'smooth'){
#      fem def mapping;r;CmissBasicFiles/LungMappingSmoothEdges;
#    } else {
#      fem def mapping;r;CmissBasicFiles/LungMappingSharpEdges;
#    }
    ###fem def mapping;r;CmissBasicFiles/MahyarMesh; 

   
    fem update field $P substitute constant $posP;

    read com;CmissComFiles/ExportResultsNonuni;
    $sum_increment = $sum_increment + $increment;
}



$Uniform='GravityTLC';
fem def init;w;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;

fem update geometry from solution;
$spacing = 4;
fem def data;c fill_volume spacing $spacing;
FEM DEFINE DATA;W;initialTLC;
fem export data;initialTLC;

$xifile = ${init_path}.'/fill_volumeTLC'.${lung}.'_'.$subject;
fem def xi;w;$xifile;


read com;CmissComFiles/SetGeometry;    #read nodes, elements
fem read com;CmissComFiles/ScaleLungToReference;

# define fields

##fem def field;r;InitialConditions/InitialMahyarMesh;
##fem def elem;r;InitialConditions/InitialMahyarMesh field;
fem def field;r;InitialConditions/Left_Initialize16Field;
fem def elem;r;InitialConditions/Left_InitialElem16Field field;


# FIBRES (DEFAULT FIELDS)
fem def fibr;d;
fem def elem;d fibre;

fem update node deriv 1 versions individual;
fem update node deriv 2 versions individual;
fem update node deriv 3 versions individual;
em update node scale_factor;


fem def equa;r;CmissBasicFiles/Compressible;
fem de mate;r;CmissBasicFiles/SEDF;
fem update material density $density;

# Do a Solve with Zero G to set up
# ---------------------------------------
fem def init;r;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;

fem def solve;r;CmissBasicFiles/GMRES;
if ($surfacetype eq 'smooth'){
  fem def mapping;r;CmissBasicFiles/LungMappingSmoothEdges;
} else {
  fem def mapping;r;CmissBasicFiles/LungMappingSharpEdges;
}
fem solve increment 1 iterate $iterate error $error;

fem export node;${init_path}/ZeroGSolveTLC as cube field;
fem export elem;${init_path}/ZeroGSolveTLC as cube field;

$i = $volume;
read com;CmissComFiles/ExportResults;

fem def init;r;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;
fem def solve;r;CmissBasicFiles/GMRES;
if ($surfacetype eq 'smooth'){
  fem def mapping;r;CmissBasicFiles/LungMappingSmoothEdges;
} else {
  fem def mapping;r;CmissBasicFiles/LungMappingSharpEdges;
}

fem solve increment 1 iterate $iterate error $error;

fem export node;${init_path}/ZeroGSolve1TLC as cube field;
fem export elem;${init_path}/ZeroGSolve1TLC as cube field;
fem def init;w;${init_path}.'/ZeroG_Uniform'.$lung.'_'.$volume;




#$spacing = 5;
$xifile = ${init_path}.'/fill_volume'.${lung}.'_'.$subject;


#fem def xi;r;$xifile;
FEM DEFINE DATA;r;initialTLC;
fem list elem total deformed;
#fem def data;c from_xi deformed;

fem update data field num_field 1;
fem update data field num_field 2;
fem evaluate compressible data recoil field 1; #in Pa
fem evaluate compressible data ratio field 2;  #dimensionless

#############$file = ${posture}.${lung}.${volume};
$file1 = 'Gravity_TLC'.${posture}.${lung}.${volume};

fem export data;${grav_path}.'/'.$file1 field_num 1,2 as result;
fem def data;w;${grav_path}.'/'.$file1 field num_field 1,2;

#$rhot = $density * 1000 * ($info{$subject}->[8]/2)/$info{$subject}->[1];
# target density = reference density * (ratio of reference volume to simulation volume)
$rhot = 1000 * $density *($ref_pct)/$volume; #g/cm^3
print "target density = $rhot \n";
print "calculated density = $density \n";

fem list elements;${grav_path}.'/'.'Element_Vol_DeformedTLC' deformed;
fem list elem total deformed;
#die;
#$density = $densityFRC/($ref_pct/100);
$size = 10;
system "perl PerlScripts/solution_bin_Gravity.pl ${grav_path}/$file1 z $size $density $rhot";
system "perl PerlScripts/solution_bin_Gravity.pl ${grav_path}/$file1 y $size $density $rhot";
system "perl PerlScripts/solution_bin_Gravity.pl ${grav_path}/$file1 x $size $density $rhot";

#### Read in the local FE coordinates for endocardial surface #######
fem define xi;r;CmissBasicFiles/FissureXi
fem define data;c from_xi deformed;
$file=FissureDataPointsTLC;
fem define data;w;${grav_path}.'/'.$file
fem list data statistics
fem export data;${grav_path}.'/'.$file as $file
$Uniform='Gravity_TLC';
fem def init;w;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;

fem quit;

