

read com;CmissComFiles/SpecifyProblem; #specify the subject, lung,simulation parameters
fem read com;CmissComFiles/BasicSetup;#REad in basic set up parameters


#DEFINE GRAVITY VECTORS FOR SPECIFIC POSTURES
#-----------------------------------------
$gvect{"Supine"}=[0, -9810,0];
$gvect{"Prone"}=[0, 9810,0];
$gvect{"Upright"}=[0, 0, 9810];


#$gvect{"Supine"}=[0, 9810,0];
#$gvect{"Prone"}=[0, -9810,0];
#$gvect{"Upright"}=[0, 0, 9810];

#SETTING STEP SIZE FOR GRAVITY INCREMENTS
#---------------------------------
$Gnsteps=12; #Number of gravity loads
$increment=1/$Gnsteps; #size of increment


#Grouping lung by properties of elements
#-------------------------------------
read com;CmissComFiles/GroupLungGravity;
fem list node group;


#Calculate and store lung surface points
#---------------------------------------
fem def data;c from_node node outer_nodes; #calculates data points and Xi coords
fem def data;w;WorkingFiles/LungSurfacePoints geometry;
fem def xi;w;WorkingFiles/LungSurfacePoints coupled_nodes;


#ARC:FROM HERE SAME AS UNIFORM EXPN
#Scale lung shape to reference volume
#----------------------------------
print "scale to ref = $scale_0 \n";
fem read com;CmissComFiles/ScaleLungToReference; #scale from TLC to Vref



# SET UP DEFAULT FIELDS 
#---------------------------------------
if($meshtype eq 'fissuremesh') {
fem def field;r;InitialConditions/Left_Initialize16Field;
fem def elem;r;InitialConditions/Left_InitialElem16Field field;
} elsif ($meshtype eq 'Nofissure_mesh') {
 if($refinement eq 'coarse') {
 fem def field;r;InitialConditions/Left_Initialize16Field_Coarsemesh;
 fem def elem;r;InitialConditions/Left_InitialElem16Field_Coarsemesh field;
 } elsif ($refinement eq 'fine') {
 fem def field;r;InitialConditions/Left_Initialize16Field_finemesh;
 fem def elem;r;InitialConditions/Left_InitialElem16Field_finemesh field;
 }
}


# SET UP DEFAULT FIBRES
#----------------------------
fem def fibr;d;
fem def elem;d fibre;

fem update node deriv 1 versions individual;
fem update node deriv 2 versions individual;
fem update node deriv 3 versions individual;
fem update node scale_factor;



# EQUATION TYPE AND MATERIAL LAW
#---------------------------------------
fem def equa;r;CmissBasicFiles/Compressible;
fem def mate;r;CmissBasicFiles/SEDF;
fem update material density $density;


# read the dispacment field 
#--------------------------------
fem def field;r;'CmissBasicFiles/Displacement'.$subject


# INITIAL CONDITIONS: SET FIXED DISPLACEMENTS AND FORCES
#em def init;r;InitialConditions/FixSurface;

## FIT ALVEOLAR PRESSURES
## em def fit;r;CmissBasicFiles/Pressure field;

#ARC:END SAME AS UNIFORM EXPN


# read the Gravity Solution
#----------------------------
$Uniform='GravitySoln';
fem def init;r;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;

fem export node;${init_path}/NonUniformSolve01 as cube field;
fem export elem;${init_path}/NonUniformSolve01 as cube field;



if($meshtype eq 'fissuremesh') {
if ($surfacetype eq 'smooth'){
fem def mapping;r;CmissBasicFiles/LungMappingSmoothEdges;
} elsif ($surfacetype eq 'sharp'){
fem def mapping;r;CmissBasicFiles/LungMappingSharpEdges;
} else {
fem quit;
}
}

if($meshtype eq 'Nofissure_mesh') {
if ($refinement eq 'coarse'){
fem def mapping;r;CmissBasicFiles/LungMapping_coarse;
}
}


fem def solve;r;CmissBasicFiles/GMRES;
fem evaluate pressure gauss;
fem solve increment 1 iterate $iterate error $error;


fem export node;${init_path}/NonUniformSolve0 as cube field;
fem export elem;${init_path}/NonUniformSolve0 as cube field;

##em def init;w;${init_path}.'/GravitySolve0_Uniform'.$lung.'_'.$volume;
fem def init;w;WorkingFiles/GravitySolve0_NonUniform;

#############################################################################################
# INITIAL CONDITIONS SET FIXED DISPLACEMENTS AND FORCES
#_-----------------------------------------------------

$ipfile = "WorkingFiles/GravitySolve0_NonUniform.ipinit"; 
$opfile = "WorkingFiles/".$posture.$lung."_FIX.ipinit";
$opfile2 = 'WorkingFiles/'.$posture.$lung.'_NOFIX.ipinit';

CORE::open(IPFILE, '<', $ipfile) or die "Error11: Can't open input file $! \n";
CORE::open(OPFILE, ">$opfile2") or die "\033[31mError11: Can't open opfile\033[0m \n";
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

if($meshtype eq 'fissuremesh') {
if ($surfacetype eq 'smooth'){
$headerfile = 'Intermediate/HeaderUniform_Smooth.ipinit';
} 
if ($surfacetype eq 'sharp'){
$headerfile = 'Intermediate/HeaderUniform_Sharp.ipinit';
}
}

if($meshtype eq 'Nofissure_mesh') {
if ($refinement eq 'coarse'){
$headerfile = 'Intermediate/HeaderNonUniform_coarse.ipinit';
####headerfile = 'Intermediate/HeaderSupineRight_coarse.ipinit';
}
}


##headerfile = 'Intermediate/Header'.'.ipinit';
##sssystem "cat $headerfile $opfile > temp.file";
##sssystem "mv temp.file $opfile";

CORE::open(IPFILE, "<$headerfile") or die "\033[31mError11: CAN't open input file $headerfile \033[0m \n";
CORE::open(OPFILE, ">$opfile") or die "\033[31mError11: Can't open $opfile\033[0m \n";
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


print "Read initial from ${init_path}.${initialfile} \n";

##em def init;r;${init_path}.'/'.${initialfile}.'_FIX';
fem def init;r;'WorkingFiles/'.$posture.$lung.'_FIX';


###############################################################################
# STORE THE CURRENT GEOMETRY (ZERO GRAVITY) IN FIELDS. USE AS PLEURAL SURFACE
#-----------------------------------------------------------------
for my $j (1..3){
    $njj[$j] = 7 + $j;
    $njs[$j] = 10 + $j;
    fem update field $njj[$j] substitute solution niy 1 depvar $j;
    fem update field $njs[$j] substitute solution niy 1 depvar $j;
}

############################################################
# FIT ALVEOLAR PRESSURES
fem def fit;r;CmissBasicFiles/Pressure field;


# STORE THE REFERENCE GEOMETRY IN FIELDS
$posP = 0;
fem update field $P substitute constant $posP; # initial pressure field


fem def mate;r;CmissBasicFiles/SEDF;
fem update material density $density;


# PROBLEM SOLUTION
fem def solve;r;CmissBasicFiles/GMRES;

fem update field $x0 nodes substitute solution niy 1 depvar 1 force;
fem update field $y0 nodes substitute solution niy 1 depvar 2 force;
fem update field $z0 nodes substitute solution niy 1 depvar 3 force;


# READ IN LOCATIONS OF NODES ON LUNG SURFACE IN THE REFERENCE STATE
fem def data;r;WorkingFiles/LungSurfacePoints coupled_nodes;
fem def xi;r;WorkingFiles/LungSurfacePoints coupled_nodes;


#####em evaluate pressure gauss; #updates ratio deformed:undeformed
#####em solve increment 1 iterate $iterate error $error;



fem export node;${init_path}/AfterFirstSolve as cube field; #debug. Does not converge here.
fem export node;${init_path}/NonUniformSolve1 as cube field;
fem export elem;${init_path}/NonUniformSolve1 as cube field;

$sum_increment = $increment;
$gravity = 0;

$TLC2FRC_Ratio=1.9    # this value designed for uniform expansion 
$scaling_ratio=($TLC2FRC_Ratio)**(1/3);
$cavity_scale=($scaling_ratio)**($increment);

#$TLC2FRC_RatioX=1.04;    # this value designed for uniform expansion 
#$TLC2FRC_RatioY=1.04;    # this value designed for uniform expansion 
#$TLC2FRC_RatioZ=1.19;    # this value designed for uniform expansion 
#$scaling_ratioX=($TLC2FRC_RatioX)**(1/3);
#$scaling_ratioY=($TLC2FRC_RatioY)**(1/3);
#$scaling_ratioZ=($TLC2FRC_RatioZ)**(1/3);
#$cavity_scaleX=($scaling_ratioX)**($increment);
#$cavity_scaleY=($scaling_ratioY)**($increment);
#$cavity_scaleZ=($scaling_ratioZ)**($increment);

print " cavity Scale is $cavity_scale\n"
print " scale ratio is $scaling_ratio\n"

print " Protocol is $protocol \n"


#------------------------------------------------------------

if ($protocol eq 'FRC' || $protocol eq 'TLC') {
#------------------------------------------------------------

$increment = $increment/1;
for ($j = 1; $j <= $Gnsteps; $j++){
   print "Solution step $j of $Gnsteps for $subject $lung $posture\n";

   print "--------------------------------------------------------\n";
   print " Solve incr TO compute Reaction forces $sum_increment \n";
   print "--------------------------------------------------------\n";

    # Step one uniform expansion 
    #-----------------------------

    fem update field $njs[1] nodes all_nodes add field 5 scale $increment;
    fem update field $njs[2] nodes all_nodes add field 6 scale $increment;
    fem update field $njs[3] nodes all_nodes add field 7 scale $increment;

    fem def equa;r;CmissBasicFiles/Compressible;
    fem def mate;r;CmissBasicFiles/SEDF;
    fem update material density $density;

#####fem update field $P substitute constant $posP;

### fem export node;${init_path}/NonUnni_BeforeUniExpn$j as cube field; #debug
### fem export elem;${init_path}/NonUnni_BeforeUniExpn$j as cube field; #debug
    print "scale cavity by $cavity_scale to $step % of TLC\n";
    
   #-------------------------------------------------------------------
   #..CHANGE THE SIZE OF THE LUNG TO MATCH THE CAVITY (update solution)
   #-------------------------------------------------------------------

  read com;CmissComFiles/ChangeLungMatchCavity;

### fem update solution niy 1 depvar 1 node all_nodes multiply constant $cavity_scaleX;
### fem update solution niy 1 depvar 2 node all_nodes multiply constant $cavity_scaleY;
### fem update solution niy 1 depvar 3 node all_nodes multiply constant $cavity_scaleZ;
    
### fem export node;${init_path}/NonUnni_AfterUniExpn$j as cube field; #debug
### fem export elem;${init_path}/NonUnni_AfterUniExpn$j as cube field; #debug
    

 ## SOLVE - PREDICTOR STEP
 #-------------------------
   # MAPPING
     if($meshtype eq 'fissuremesh') {
     if ($surfacetype eq 'smooth'){
     fem def mapping;r;CmissBasicFiles/LungMappingSmoothEdges;
     } elsif ($surfacetype eq 'sharp'){
     fem def mapping;r;CmissBasicFiles/LungMappingSharpEdges;
     } else {
     fem quit;
     }
     }
     if($meshtype eq 'Nofissure_mesh') {
     if ($refinement eq 'coarse'){
     fem def mapping;r;CmissBasicFiles/LungMapping_coarse;
     }
     }    
    fem def solve;r;CmissBasicFiles/GMRES;
    fem update field $P substitute constant $posP;

    fem evaluate pressure gauss;
    fem solve increment 1 iterate $iterate error $error;
 #--------------------------------------------------------

###### UPDATE FORCES
#####---------------------------------------
     read com;CmissComFiles/ModifyInitial;
#####---------------------------------------

    ################# Projection Steps ############################
    fem export node;${init_path}/NonUnni_BeforeProject$j as cube field;
    fem export elem;${init_path}/NonUnni_BeforeProject$j as cube field;
    
     if($meshtype eq 'fissuremesh') {
     if ($surfacetype eq 'smooth'){
       read com;CmissComFiles/ProjectNormal_SmoothEdges;
     } 
     if ($surfacetype eq 'sharp'){
       read com;CmissComFiles/ProjectNormal_SharpEdges;
     }
     }
     if($meshtype eq 'Nofissure_mesh') {
     if ($refinement eq 'coarse'){
     read com;CmissComFiles/ProjectNonUniform_coarse;
     }
     }

## em update solution niy 1 depvar 1 node all_nodes substitute field $njs[1];
## em update solution niy 1 depvar 2 node all_nodes substitute field $njs[2];
## em update solution niy 1 depvar 3 node all_nodes substitute field $njs[3];


    fem export node;${init_path}/NonUnni_AftProject$j as cube field;
    fem export elem;${init_path}/NonUnni_AftProject$j as cube field;   

    #---------------------------------------------
     read com;CmissComFiles/OutputInitialNonUniform;
    #---------------------------------------------

###### UPDATE FORCES - CORRECTOR
#####---------------------------------------
     read com;CmissComFiles/ModifyInitial;
#####---------------------------------------

    $i++;
    read com;CmissComFiles/ExportResultsNonuni;
    $sum_increment = $sum_increment + $increment;
}
}


###########################################################################
###########################################################################

if ($protocol eq 'Supine' || $protocol eq 'Prone') {
$increment = $increment/1;
for ($j = 1; $j <= $Gnsteps; $j++){
   print "Solution step $j of $Gnsteps for $subject $lung $posture\n";

   print "--------------------------------------------------------\n";
   print " Solve incr TO compute Reaction forces $sum_increment \n";
   print "--------------------------------------------------------\n";

   # Step one uniform expansion 
   #-----------------------------

    fem update field $njs[1] nodes all_nodes add field 5 scale $increment;
    fem update field $njs[2] nodes all_nodes add field 6 scale $increment;
    fem update field $njs[3] nodes all_nodes add field 7 scale $increment;

    fem def equa;r;CmissBasicFiles/Compressible;
    fem def mate;r;CmissBasicFiles/SEDF;
    fem update material density $density;

####fem update field $P substitute constant $posP;

## fem export node;${init_path}/NonUnni_BeforeUniExpn$j as cube field; #debug
## fem export elem;${init_path}/NonUnni_BeforeUniExpn$j as cube field; #debug
    print "scale cavity by $cavity_scale to $step % of TLC\n";
    
   #----------------------------------------------------------------
   #..CHANGE THE SIZE OF THE LUNG TO MATCH THE CAVITY (update solution)
   #----------------------------------------------------------------
   fem update solution niy 1 depvar 1 node all_nodes substitute field $njs[1];
   fem update solution niy 1 depvar 2 node all_nodes substitute field $njs[2];
   fem update solution niy 1 depvar 3 node all_nodes substitute field $njs[3];


### fem export node;${init_path}/NonUnni_AfterUniExpn$j as cube field; #debug
### fem export elem;${init_path}/NonUnni_AfterUniExpn$j as cube field; #debug
    

    ## SOLVE - PREDICTOR STEP
    #--------------------------------------------------------
     # MAPPING
     if($meshtype eq 'fissuremesh') {
     if ($surfacetype eq 'smooth'){
     fem def mapping;r;CmissBasicFiles/LungMappingSmoothEdges;
     } elsif ($surfacetype eq 'sharp'){
     fem def mapping;r;CmissBasicFiles/LungMappingSharpEdges;
     } else {
     fem quit;
     }
     }
     if($meshtype eq 'Nofissure_mesh') {
     if ($refinement eq 'coarse'){
     fem def mapping;r;CmissBasicFiles/LungMapping_coarse;
     }
     }    
    fem def solve;r;CmissBasicFiles/GMRES;
    fem update field $P substitute constant $posP;

    fem evaluate pressure gauss;
    fem solve increment 1 iterate $iterate error $error;
  #--------------------------------------------------------

###### UPDATE FORCES
#####---------------------------------------
    read com;CmissComFiles/ModifyInitial;
#####---------------------------------------

    ################# Projection Steps ############################
    fem export node;${init_path}/NonUnni_BeforeProject$j as cube field;
    fem export elem;${init_path}/NonUnni_BeforeProject$j as cube field;
    
     if($meshtype eq 'fissuremesh') {
     if ($surfacetype eq 'smooth'){
       read com;CmissComFiles/ProjectNormal_SmoothEdges;
     } 
     if ($surfacetype eq 'sharp'){
       read com;CmissComFiles/ProjectNormal_SharpEdges;
     }
     }
     if($meshtype eq 'Nofissure_mesh') {
     if ($refinement eq 'coarse'){
     read com;CmissComFiles/ProjectNonUniform_coarse;
     }
     }

##em update solution niy 1 depvar 1 node all_nodes substitute field $njs[1];
##em update solution niy 1 depvar 2 node all_nodes substitute field $njs[2];
##em update solution niy 1 depvar 3 node all_nodes substitute field $njs[3];

    if($TLC2FRC_Ratio lt 1.4) {
    #FREE SOLVE TO UPDATE 
    #---------------------------------------------
     read com;CmissComFiles/OutputInitialNonUniform_1;
    #---------------------------------------------

     if($meshtype eq 'Nofissure_mesh') {
     if ($refinement eq 'coarse'){
     read com;CmissComFiles/ProjectNonUniform_coarse;
     }
     }
    }


    fem export node;${init_path}/NonUnni_AftProject$j as cube field;
    fem export elem;${init_path}/NonUnni_AftProject$j as cube field;   

    #---------------------------------------------
     read com;CmissComFiles/OutputInitialNonUniform_2;
    #---------------------------------------------

###### UPDATE FORCES - CORRECTOR
#####---------------------------------------
     read com;CmissComFiles/ModifyInitial;
#####---------------------------------------

    $i++;
    read com;CmissComFiles/ExportResultsNonuni;
    $sum_increment = $sum_increment + $increment;
}
}

print "-------------\n";
fem list elem total deformed;
print "-------------\n";
fem list elem total;
print "-------------\n";
#######em update geometry from solution;
print "-------------\n";
fem list elem total;

fem quit;

#######################################################
######################################################
## post-process
##-------------

$xifile = $grav_path.'/fill_volume'.${lung}.'_'.$subject;

 $spacing = 4;
 fem def data;c fill_volume spacing $spacing;
 fem def xi;w;$xifile;

 fem list elem total deformed;
 fem def data;c from_xi deformed;

 fem update data field num_field 2;
 fem update data field num_field 1;
 fem evaluate compressible data recoil field 1; #in Pa
 fem evaluate compressible data ratio field 2;  #dimensionless

$file = ${posture}.'NonUni'.${lung}.${volume};

fem export data;${grav_path}.'/'.$file field_num 1,2 as result;
fem def data;w;${grav_path}.'/'.$file field num_field 2;

$rhot = 1000 * $density *($ref_pct)/$volume; #g/cm^3
print "target density = $rhot \n";

$size = 10;
system "perl PerlScripts/solution_bin.pl ${grav_path}/${file} z $size $density $rhot";
system "perl PerlScripts/solution_bin.pl ${grav_path}/${file} y $size $density $rhot";
system "perl PerlScripts/solution_bin.pl ${grav_path}/${file} x $size $density $rhot";

$size = 40;
system "perl PerlScripts/solution_bin.pl ${grav_path}/${file} z $size $density $rhot";
system "perl PerlScripts/solution_bin.pl ${grav_path}/${file} y $size $density $rhot";

$size = 35;
system "perl PerlScripts/solution_bin.pl ${grav_path}/${file} y $size $density $rhot";

$size = 80;
system "perl PerlScripts/solution_bin.pl ${grav_path}/${file} z $size $density $rhot";

fem Quit;





