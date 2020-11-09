
# UPDATE THE GEOMETRY VIA NORMAL PROJECTION
###############################################
fem def xi;r;WorkingFiles/LungSurfacePoints coupled_nodes;
fem def data;c from_xi deformed coupled_nodes;
fem def data;w;WorkingFiles/CurrentSurfacePoints coupled_nodes;

for my $j (1..3){
   fem update field $njj[$j] substitute solution niy 1 depvar $j;  }
 

##fem def data;c from_node node outer_nodes; #calculates data points and Xi coords
##fem def data;w;WorkingFiles/CurrentSurfacePoints coupled_nodes;


# PROJECT SIDES
################

###em update xi points side1 faces side1_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
###em update xi points side2 faces side2_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
###em update xi points base faces side3_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

fem update xi points sides faces outer_faces from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];


##em def data;w;WorkingFiles/CurrentSurfacePoints coupled_nodes;

#Projectecting the middle base  
#########################
fem update xi points base_mid faces side3_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];


##em def data;r;WorkingFiles/CurrentSurfacePoints coupled_nodes;


# project Base Edges 
####################
##fem update xi points base_edge1 faces side1_lung edge free 3 xi2 0 xi3 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
##fem update xi points base_edge2 faces side2_lung edge free 3 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

fem update xi points base_edge_2 faces side1_lung edge xi2 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
fem update xi points base_edge_1 faces side2_lung edge xi2 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];


##em def data;r;WorkingFiles/CurrentSurfacePoints coupled_nodes;


# PROJECT EDGES
#################

fem update xi points edge_back faces side2_lung edge xi1 0 from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];



# PROJECT TOPS
####################
##em update xi points top faces side2_lung edge free 1 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

##em update xi points top_side_1 faces side2_lung edge free 2 xi1 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
##em update xi points top_side_2 faces side2_lung edge free 1 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

##em def data;r;WorkingFiles/CurrentSurfacePoints coupled_nodes;

## TEMP COMMENT
fem update xi points tops faces top_faces from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];




###############################################################################
###############################################################################
	
# X-AXIS PROJECTION
fem update solution niy 1 depvar 1 node project_x substitute field $njj[1];

# Y-AXIS PROJECTION
fem update solution niy 1 depvar 2 node project_y substitute field $njj[2];

# Z-AXIS PROJECTION
fem update solution niy 1 depvar 3 node project_z substitute field $njj[3];

###########################################################################
######################## Project back the front edge corner node 57 ##########

# X-AXIS PROJECTION
fem update solution niy 1 depvar 1 node edge_front,33,37 substitute field $njs[1];

# Y-AXIS PROJECTION
fem update solution niy 1 depvar 2 node edge_front,33,37 substitute field $njs[2];

# Z-AXIS PROJECTION
fem update solution niy 1 depvar 3 node edge_front,33,37 substitute field $njs[3];


### EXTRAAAS
##em update solution niy 1 depvar 1 node inner_nodes substitute field $njs[1];
##em update solution niy 1 depvar 2 node inner_nodes substitute field $njs[2];
##em update solution niy 1 depvar 3 node inner_nodes substitute field $njs[3];


