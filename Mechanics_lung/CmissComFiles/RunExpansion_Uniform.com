
read com;CmissComFiles/SpecifyProblem; #specify the subject, lung,simulation parameters
fem read com;CmissComFiles/BasicSetup;#REad in basic set up parameters


#Grouping lung by properties of elements
#----------------------------------------
read com;CmissComFiles/GroupLung;


#Scale lung shape to reference volume
print "scale to ref = $scale_0 \n";
fem read com;CmissComFiles/ScaleLungToReference; #scale from TLC to Vref


# SET UP DEFAULT FIELDS     # 
fem def field;r;InitialConditions/Left_Initialize16Field;
fem def elem;r;InitialConditions/Left_InitialElem16Field field;


# SET UP DEFAULT FIBRES
fem def fibr;d;
fem def elem;d fibre;

fem update node deriv 1 versions individual;
fem update node deriv 2 versions individual;
fem update node deriv 3 versions individual;
fem update node scale_factor;


# EQUATION TYPE AND MATERIAL LAW
fem def equa;r;CmissBasicFiles/Compressible;
fem def mate;r;CmissBasicFiles/SEDF;
fem update material density $density;


# INITIAL CONDITIONS: SET FIXED DISPLACEMENTS AND FORCES
fem update material density $density;

# INITIAL CONDITIONS: SET FIXED DISPLACEMENTS AND FORCES
fem def init;r;InitialConditions/FixSurface;

# FIT ALVEOLAR PRESSURES
fem def fit;r;CmissBasicFiles/Pressure field;

#output undeformed mesh
fem export node;$init_path/D0 as cube field;
fem export node;$init_path/U0 as cube;
fem export elem;$init_path/D0 as cube field;
fem export elem;$init_path/U0 as cube;


# PROBLEM SOLUTION
fem def mapping;r;CmissBasicFiles/LungMapping; 
fem def solve;r;CmissBasicFiles/GMRES;

#SOLVE TO GET EXPANDING FORCES
fem evaluate pressure gauss;       #updates ratio deformed:undeformed
fem solve increment 0 iterate $iterate error $error;

#Export expanded solution
fem export node;$init_path/D1 as cube field;
fem export node;$init_path/U1 as cube;
fem export elem;$init_path/D1 as cube field;
fem export elem;$init_path/U1 as cube;
fem evaluate pressure gauss;

$sum_increment = 0;
$i=0;
$previous=$ref_pct;
print "scale_steps @scale_steps\n";
foreach $step (@scale_steps){
    $cavity_scale=($step/$previous)**(1/3);
    print "scale cavity by $cavity_scale to $step % of expansion\n";

    #..CHANGE THE SIZE OF THE LUNG TO MATCH THE CAVITY (update solution)
    read com;CmissComFiles/ChangeLungMatchCavity;

#####..CALCULATE THE FORCES REQUIRED TO MAINTAIN THIS GEOMETRY
    fem evaluate pressure gauss; #updates ratio deformed:undeformed
    read com;CmissComFiles/OutputInitial;

##..EXPORT THE RESULTS
    $i++;
    fem export node;${init_path}/D$i as cube field;
    fem export node;${init_path}/U$i as cube;

    #..MODIFY THE INITIAL FORCES TO MAINTAIN THE GEOMETRY
    $mod = 1;
    read com;CmissComFiles/ModifyInitial;
    fem def solve;r;CmissBasicFiles/GMRES;
    fem update field $P substitute constant 0;
    fem evaluate pressure gauss;
    fem solve increment 1 iterate $iterate error $error;

#..CALCULATE THE PRESSURES NEAR THE SURFACE
    fem evalu press surface faces outer_faces at 0.95 field 1;
    fem update field 1 multiply constant 1/98; #Pa to cmH2O

##..EXPORT THE RESULTS
    $i++;
    fem export node;${init_path}/D$i as cube field;
    fem export node;${init_path}/U$i as cube;

    fem update field $P substitute constant 0;

    fem list stress elem 20 at 2;

    $Uniform='Uniform';
    fem def init;w;${init_path}.'/'.$Uniform.${lung}.'_'.$step;
    $previous = $step;

}

fem export gauss;lunggausspts as lunggauss
fem quit;

$spacing = 5;
fem def data;c fill_volume spacing $spacing;
fem def data;c from_xi deformed;
fem update data field num_field 2;
fem evaluate compressible data recoil field 1;
fem evaluate compressible data ratio field 2;
$file = 'UniExpan'.${posture}.${lobe};
fem export data;${grav_path}.'/'.$file field_num 1,2 as result;
fem de data;w;${grav_path}.'/'.$file field num_field 2;
fem list elem total deformed;



fem list elements;${grav_path}.'/'.'Element_Vol_DeformedUniform' deformed;


$rhot = 1000 * $density *($ref_pct)/$volume; #g/cm^3
print "target density = $rhot \n";
print "Density=$density \n";
print "Rhot=$rhot \n";  

fem def init;w;${init_path}.'/Uniform'.$lung.'_'.$volume;
fem list elem total deformed;
$size = 10;

system "perl PerlScripts/solution_bin.pl ${grav_path}/$file z $size $density $rhot";
system "perl PerlScripts/solution_bin.pl ${grav_path}/$file y $size $density $rhot";
system "perl PerlScripts/solution_bin.pl ${grav_path}/$file x $size $density $rhot";

#### SurfaceNode on fissure (Zero Gravity)#######
fem define xi;r;CmissBasicFiles/FissureXi
fem define data;c from_xi

$file=FissureDataPoints
fem define data;w;${grav_path}.'/'.$file
fem list data statistics
fem quit;

