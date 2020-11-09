


# UPDATE THE GEOMETRY VIA NORMAL PROJECTION
###############################################
fem def xi;r;WorkingFiles/LungSurfacePoints coupled_nodes;
fem def data;c from_xi deformed coupled_nodes;
fem def data;w;WorkingFiles/CurrentSurfacePoints coupled_nodes;



for my $j (1..3){
   fem update field $njj[$j] substitute solution niy 1 depvar $j;  }
 

##fem def data;c from_node node outer_nodes; #calculates data points and Xi coords
##fem def data;w;WorkingFiles/CurrentSurfacePoints coupled_nodes;


######################## Project back the front edge corner node 57 ##########

# X-AXIS PROJECTION
fem update solution niy 1 depvar 1 node edge_front,33,37 substitute field $njs[1];

# Y-AXIS PROJECTION
fem update solution niy 1 depvar 2 node edge_front,33,37 substitute field $njs[2];

# Z-AXIS PROJECTION
fem update solution niy 1 depvar 3 node edge_front,33,37 substitute field $njs[3];



