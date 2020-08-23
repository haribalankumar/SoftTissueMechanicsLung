
##ARC: THE CODE BELOW IS WRITTEN BY HAMED TO CREATE DATA POINTS FOR ANALYSIS. I HAVE NOT CHECKED THIS CODE
$Uniform='Gravity';
fem def init;w;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;

#################### Create Uniform Data points
fem update geometry from solution;
$spacing = 4;
fem def data;c fill_volume spacing $spacing;

#FEM DEFINE DATA;W;initial;
#fem export data;initial;

$xifile = ${init_path}.'/fill_volume'.${lung}.'_'.$subject;
fem def xi;w;$xifile;


read com;CmissComFiles/SetGeometry;    #read nodes, elements
fem read com;CmissComFiles/ScaleLungToReference;

# define fields
#----------------
fem def field;r;InitialConditions/Left_Initialize16Field;
fem def elem;r;InitialConditions/Left_InitialElem16Field field;

##fem def field;d field_var 16 vers deriv; #MUST have versions of fields #original
##fem def elem;d field; #original


# FIBRES (DEFAULT FIELDS)
#------------------------
fem def fibr;d;
fem def elem;d fibre;

fem update node deriv 1 versions individual;
fem update node deriv 2 versions individual;
fem update node deriv 3 versions individual;
fem update node scale_factor;


fem def equa;r;CmissBasicFiles/Compressible;
fem def mate;r;CmissBasicFiles/SEDF;
fem update material density $density;


# Do a Solve with Zero G to set up
# ---------------------------------------
fem def init;r;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;

fem def solve;r;CmissBasicFiles/GMRES;
fem def mapping;r;CmissBasicFiles/LungMapping;
fem solve increment 1 iterate $iterate error $error;

fem export node;${init_path}/ZeroGSolve1 as cube field;
fem export elem;${init_path}/ZeroGSolve1 as cube field;

$i = $volume;
read com;CmissComFiles/ExportResults;

fem def init;r;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;
fem def solve;r;CmissBasicFiles/GMRES;

fem def mapping;r;CmissBasicFiles/LungMapping;
fem solve increment 1 iterate $iterate error $error;

fem export node;${init_path}/ZeroGSolve10 as cube field;
fem export elem;${init_path}/ZeroGSolve10 as cube field;


fem def init;w;${init_path}.'/ZeroG_Uniform'.$lung.'_'.$volume;

###3$spacing = 5;
$xifile = ${init_path}.'/fill_volume'.${lung}.'_'.$subject;

fem def xi;r;$xifile;
fem list elem total deformed;
fem def data;c from_xi deformed;

fem update data field num_field 1;
fem update data field num_field 2;
fem evaluate compressible data recoil field 1; #in Pa
fem evaluate compressible data ratio field 2;  #dimensionless

####$file = ${posture}.${lung}.${volume};
$file1 = 'Gravity_'.${posture}.${lung}.${volume};

fem export data;${grav_path}.'/'.$file1 field_num 1,2 as result;
fem def data;w;${grav_path}.'/'.$file1 field num_field 1,2;

$rhot = 1000 * $density *($ref_pct)/$volume; #g/cm^3
print "target density = $rhot \n";
print "calculated density = $density \n";

fem list elements;${grav_path}.'/'.'Element_Vol_DeformedGravity' deformed;
fem list elem total deformed;

$density = $densityFRC/($ref_pct/100);
$size = 10;
system "perl PerlScripts/solution_bin_Gravity.pl ${grav_path}/$file1 z $size $density $rhot";
system "perl PerlScripts/solution_bin_Gravity.pl ${grav_path}/$file1 y $size $density $rhot";
system "perl PerlScripts/solution_bin_Gravity.pl ${grav_path}/$file1 x $size $density $rhot";

#### Read in the local FE coordinates for endocardial surface #######
fem def xi;r;CmissBasicFiles/FissureXi
fem def data;c from_xi deformed;
$file='FissureDataPointsGravity';

fem def data;w;${grav_path}.'/'.$file
fem list data statistics
fem export data;${grav_path}.'/'.$file as $file

$Uniform='Gravity_TLC';
fem def init;w;${init_path}.'/'.$Uniform.${lung}.'_'.$volume;

