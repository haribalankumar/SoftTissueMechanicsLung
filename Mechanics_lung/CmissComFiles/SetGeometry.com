# GEOMETRY OF LUNG AND PLEURAL CAVITY AT volume that you wish to simulate

if($refined eq 'zeroG'){
  fem de node;r;$Model/${lung}_zeroG;
  fem de elem;r;$Model/${lung}_zeroG basis 1;
}else{
   fem de node;r;$Model/${lung}_fitted;
   fem de elem;r;$geometry_path/left_volume basis 1; #generic element structure
}


