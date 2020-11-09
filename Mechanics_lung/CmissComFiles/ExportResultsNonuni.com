
#..CALCULATE THE PRESSURES NEAR THE SURFACE
#em evalu press surface faces outer_faces at 0.95 field 1;
#em update field 1 multiply constant 1/98; #Pa to cmH2O


#..EXPORT THE RESULTS
fem export node;$grav_path/D0GNonuni${output}$i as cube field;
#fem export node;$grav_path/UGNonuni${output}$i as cube;

fem export elem;$grav_path/D0GNonuni${output}$i as cube field;
#fem export elem;$grav_path/UGNonuni${output}$i as cube;

##..WRITE OUT THE INITIAL CONDITIONS
fem def init;w;${grav_path}/Final${output}$i;