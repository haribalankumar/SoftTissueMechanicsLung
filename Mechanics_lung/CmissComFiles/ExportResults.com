
#..CALCULATE THE PRESSURES NEAR THE SURFACE
fem evalu press surface faces outer_faces at 0.95 field 1;
fem update field 1 multiply constant 1/98; #Pa to cmH2O


#..EXPORT THE RESULTS
fem export elem;$grav_path/DG${output}$i as cube field;
fem export elem;$grav_path/UG${output}$i as cube;
fem export node;$grav_path/DG${output}$i as cube field;
fem export node;$grav_path/UG${output}$i as cube;
##die;



##..WRITE OUT THE INITIAL CONDITIONS
#em def init;w;${grav_path}/Final${output}$i;
