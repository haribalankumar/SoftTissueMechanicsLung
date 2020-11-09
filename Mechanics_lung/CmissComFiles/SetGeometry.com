


# GEOMETRY OF LUNG AND PLEURAL CAVITY AT volume that you wish to simulate

if($refined eq 'zeroG'){
  fem de node;r;$Model/${lung}_zeroG;
  fem de elem;r;$Model/${lung}_zeroG basis 1;
}else{
}


if($meshtype eq 'fissuremesh') {
if ($surfacetype eq 'smooth'){
   fem def node;r;$Model/${lung}_fitted;
   fem de elem;r;$geometry_path/left_volume basis 1; 
} elsif ($surfacetype eq 'sharp'){
} else {
fem quit;
}
}


if($meshtype eq 'Nofissure_mesh') {
if ($refinement eq 'coarse'){
   fem def node;r;$Model.'/NoFisCoarsemesh/'.${lung}.'_Refittedmv';
#  fem def node;r;$Model.'/'.${lung}.'_fitted';
   fem def elem;r;$root.'/GeometricModels/FittingLungs/Files/Initial_coarse' basis 1; 
}
}


