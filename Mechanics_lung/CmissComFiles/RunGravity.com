
read com;CmissComFiles/SpecifyProblem; #specify the subject, lung,simulation parameters
fem read com;CmissComFiles/BasicSetup;#REad in basic set up parameters

#DEFINE GRAVITY VECTORS FOR SPECIFIC POSTURES
$gvect{"Supine"}=[0, -9810,0];
$gvect{"Prone"}=[0, 9810,0];
$gvect{"Upright"}=[0, 0, 9810];

#SETTING STEP SIZE FOR GRAVITY INCREMENTS
$Gnsteps=10; #Number of gravity loads
$increment=1/$Gnsteps; #size of increment

#Grouping lung by properties of elements
read com;CmissComFiles/GroupLungGravity;
fem list node group;

#Calculate and store lung surface points
fem def data;c from_node node outer_nodes; #calculates data points and Xi coords
fem def data;w;WorkingFiles/LungSurfacePoints geometry;
fem def xi;w;WorkingFiles/LungSurfacePoints coupled_nodes;

#ARC:FROM HERE SAME AS UNIFORM EXPN
#Scale lung shape to reference volume
print "scale to ref = $scale_0 \n";
fem read com;CmissComFiles/ScaleLungToReference; #scale from TLC to Vref

# SET UP DEFAULT FIELDS 
fem def field;r;InitialConditions/Left_Initialize16Field;
fem def elem;r;InitialConditions/Left_InitialElem16Field field;

### SET UP DEFAULT FIELDS  
####fem def field;r;InitialConditions/InitialMesh;
####fem def elem;r;InitialConditions/InitialMesh field;

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

#ARC:END SAME AS UNIFORM EXPN

$Uniform='Uniform';
fem def init;r;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;
fem def solve;r;CmissBasicFiles/GMRES;
fem def mapping;r;CmissBasicFiles/LungMapping; 
fem solve increment 1 iterate $iterate error $error;

fem export node;${init_path}/GravitySolve0 as cube field;
fem export elem;${init_path}/GravitySolve0 as cube field;
fem def init;w;${init_path}.'/GravitySolve0_Uniform'.$lung.'_'.$volume;


# INITIAL CONDITIONS SET FIXED DISPLACEMENTS AND FORCES
$ipfile = ${init_path}.'/GravitySolve0_Uniform'.$lung.'_'.$volume.'.ipinit'; #initial geometry and forces
$opfile = ${init_path}.'/'.${initialfile}.'_FIX.ipinit';
$opfile2 = ${init_path}.'/'.${initialfile}.'_NOFIX.ipinit';

CORE::open(IPFILE, "<$ipfile") or die "\033[31mError11: Can't open input file $ipfile \033[0m \n";
CORE::open(OPFILE, ">$opfile2") or die "\033[31mError11: Can't open $opfile\033[0m \n";
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
$headerfile = 'Intermediate/Header'.$posture.$lung.'.ipinit';

#$headerfile = 'Intermediate/Header'.'.ipinit';

#sssystem "cat $headerfile $opfile > temp.file";
#sssystem "mv temp.file $opfile";

CORE::open(IPFILE, "<$headerfile") or die "\033[31mError11: Can't open input file $headerfile1 \033[0m \n";
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

fem def init;r;${init_path}.'/'.${initialfile}.'_FIX';



# STORE THE CURRENT GEOMETRY (ZERO GRAVITY) IN FIELDS. USE AS PLEURAL SURFACE
for my $j (1..3){
    $njj[$j] = 4 + $j;
    $njs[$j] = 10 + $j;
    fem update field $njj[$j] substitute solution niy 1 depvar $j;
    fem update field $njs[$j] substitute solution niy 1 depvar $j;
}


# FIT ALVEOLAR PRESSURES
fem def fit;r;CmissBasicFiles/Pressure field;


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

    fem export node;${init_path}/Project0GG as cube field;
    fem export elem;${init_path}/Project0GG as cube field;

$sum_increment = $increment;
$gravity = 0;

$increment = $increment/1;
$i = 0;
for ($j = 1; $j <= 3; $j++){
#or ($j = 1; $j <= $Gnsteps; $j++){
    print "Solution step $j of $Gnsteps for $subject $lung $posture\n";
    fem def solve;r;CmissBasicFiles/GMRES;
    fem define mapping;r;CmissBasicFiles/LungMapping;
    fem update field $P substitute constant $posP;
    fem evaluate pressure gauss;

    fem solve increment $sum_increment iterate $iterate error $error;
    read com;CmissComFiles/ProjectNewNormal;

    fem export node;${init_path}/Project$i as cube field;
    fem export elem;${init_path}/Project$i as cube field;

    read com;CmissComFiles/OutputInitialGravity;
    read com;CmissComFiles/ModifyInitial;

    $i++;
    read com;CmissComFiles/ExportResults;
    $sum_increment = $sum_increment + $increment;
}


#####################################################
$xifile = $grav_path.'/fill_volume'.${lung}.'_'.$subject;

 fem def data;c fill_volume spread xi spacing 0.1;
 fem def xi;w;$xifile;

 fem list elem total deformed;
 fem def data;c from_xi deformed;

 fem update data field num_field 2;
 fem update data field num_field 1;
 fem evaluate compressible data recoil field 1; #in Pa
 fem evaluate compressible data ratio field 2;  #dimensionless

$file = ${posture}.${lung}.${volume};

fem export data;${grav_path}.'/'.$file field_num 1,2 as result;
fem def data;w;${grav_path}.'/'.$file field num_field 2;

$rhot = 1000 * $density *($ref_pct)/$volume; #g/cm^3
print "target density = $rhot \n";

$size = 10;
system "perl PerlScripts/solution_bin.pl ${grav_path}/${file} z $size $density $rhot";
system "perl PerlScripts/solution_bin.pl ${grav_path}/${file} y $size $density $rhot";
system "perl PerlScripts/solution_bin.pl ${grav_path}/${file} x $size $density $rhot";

#############################################################



fem quit;
