
set echo on;
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

#ystem("cat Intermediate/HeaderUniformExpansion.ipinit $opfile > Intermediate/temp.file");
#ystem("mv Intermediate/temp.file $opfile");

$headerfile1 = "Intermediate/HeaderUniformExpansion.ipinit";

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

system "rm $opfile";
system "rm $ipfile";
system "rm $opfile2";


#THIS SOLVE GIVES THE REACTIONS AT THE SURFACE NODES
#----------------------------------------------------

fem def solve;r;CmissBasicFiles/LU;

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


fem evaluate pressure gauss;
print "--------------------------------------------------------\n";
print " Solve incr TO compute Reaction forces $sum_increment \n";
print "--------------------------------------------------------\n";
fem solve increment $sum_increment iterate $iterate error $error; #no extra G


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

$headerfile2 = "Intermediate/HeaderUniformExpansion.ipinit";

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

