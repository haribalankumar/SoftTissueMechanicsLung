
fem update field 1 substitute constant $posP;
fem def init;w;Intermediate/step;

####################################################3
$ipfile = 'Intermediate/step.ipinit';
$opfile = 'Intermediate/step_FIX.ipinit';
$opfile2 = 'Intermediate/step_NOFIX.ipinit';

CORE::open(IPFILE, "<$ipfile") or die "\Can't open input file\n";
CORE::open(OPFILE, ">$opfile2") or die "\Can't open output file\n";
$line = <IPFILE>;
$print = 0;
while ($line){
    if ($line =~ / Dependent variable initial conditions:/){$print = 1;}
    if ($print == 1){print OPFILE "$line";}
    $line = <IPFILE>;
} #while
CORE::close IPFILE;
CORE::close OPFILE;


if($idisptest eq 'true') {
$headerfile1 = "Intermediate/HeaderNonUniformdispBC_coarse.ipinit";}

if($idisptest eq 'false') {
$headerfile1 = "Intermediate/HeaderNonUniformdispProject_coarse.ipinit";}

####$headerfile1 = "Intermediate/HeaderSupineRightNonUni_coarse.ipinit";

CORE::open(IPFILE, "<$headerfile1") or die "\033[31mError11: Can't open input file $headerfile1 \033[0m \n";
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

fem def init;r;Intermediate/step_FIX;

####################################################3
system "rm $opfile";
system "rm $ipfile";
system "rm $opfile2";


# MAPPING
#######################
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


fem def solve;r;CmissBasicFiles/LU;

###THIS SOLVE GIVES THE REACTIONS AT THE SURFACE NODES
###----------------------------------------------------


print "Solve Force update iteration $j \n";
print "---------------------------------------------------------\n";
fem evaluate pressure gauss;
fem solve increment 1 iterate $iterate error $error; #no extra G


fem def init;w;Intermediate/back;
####################################################3
$ipfile = 'Intermediate/back.ipinit';
$opfile = 'Intermediate/back_FIX.ipinit';
$opfile2 = 'Intermediate/back_NOFIX.ipinit';

CORE::open(IPFILE, "<$ipfile") or die "\Can't open input file\n";
CORE::open(OPFILE, ">$opfile2") or die "\Can't open output file\n";
$line = <IPFILE>;
$print = 0;
while ($line){
    if ($line =~ / Dependent variable initial conditions:/){$print = 1;}
    if ($print == 1){ print OPFILE "$line"; }
    $line = <IPFILE>;
} #while
close IPFILE;
close OPFILE;

##ystem "cat Intermediate/HeaderUniformExpansion.ipinit $opfile > Intermediate/temp.file";
##ystem "mv Intermediate/temp.file $opfile";



$headerfile2 = "Intermediate/HeaderNonUniformZeroG_coarse.ipinit";


CORE::open(IPFILE, "<$headerfile2") or die "\033[31mError11: Can't open input file $headerfile1 \033[0m \n";
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

####################################################3
fem def init;r;Intermediate/back_FIX;

system "rm $opfile";
system "rm $ipfile";

####################################################3

