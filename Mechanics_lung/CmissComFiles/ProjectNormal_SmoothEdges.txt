

# UPDATE THE GEOMETRY VIA NORMAL PROJECTION
###############################################
fem def xi;r;WorkingFiles/LungSurfacePoints coupled_nodes;
fem def data;c from_xi deformed coupled_nodes;
fem def data;w;WorkingFiles/CurrentSurfacePoints coupled_nodes;# field $njj[1] $njj[2] $njj[3]; #write out the previous location of the nodes

for my $j (1..3){
    fem update field $njj[$j] substitute solution niy 1 depvar $j;
}
    
##read com;CmissComFiles/ProjectBaseEdge;

#################### Projectecting the middle base  #########################
fem update xi points baseMiddle faces baseMiddleFace from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];


# project Base Edges 
####################
#fem update xi points BaseEdge_Side1 faces side1_lung edge free 3 xi2 0 xi3 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
#fem update xi points BaseEdge_Side2 faces side2_lung edge free 3 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

#em update xi points BaseEdge_Side1 faces side1_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
#em update xi points BaseEdge_Side2 faces side2_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

fem update xi points BaseEdge_Side1 faces outer_faces from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
fem update xi points BaseEdge_Side2 faces outer_faces from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];



# PROJECT EDGES
#################
##em update xi points edge_back faces side2_lung edge free 2 xi1 0 xi3 1 from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];
fem update xi points edge_back faces outer_faces from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];

####em update xi points edge_front faces side2_lung edge free 2 xi1 1 xi3 1 from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];
###em update xi points EdgeNode70_80_89 faces side2_lung edge xi1 0 xi3 1 from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];
###em update xi points EdgeNode70_80_89 faces side2_lung edge xi1 0 xi3 1 from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];
###em update xi points EdgeNode70_80_89 faces side1_lung,side2_lung edge xi1 0 xi3 1 from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];
fem update xi points EdgeNode70_80_89 faces frontaledge_faces from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];



# PROJECT TOPS
####################
#em update xi points top faces side2_lung edge free 1 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
#em update xi points top_side_1 faces side2_lung edge free 2 xi1 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
#em update xi points top_side_2 faces side2_lung edge free 1 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

fem update xi points top_side_1,top_side_2 faces outer_faces from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];


# PROJECT SIDES
################

###em update xi points side1 faces side1_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
###em update xi points side2 faces side2_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

####em update xi points base faces side3_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

fem update xi points Sides_Without_Corner faces outer_faces from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
fem update xi points LOblique_fissure faces outer_faces from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];



fem def data;w;WorkingFiles/CurrentSurfacePoints coupled_nodes;


	
# X-AXIS PROJECTION
fem update solution niy 1 depvar 1 node project_x substitute field $njj[1];

# Y-AXIS PROJECTION
fem update solution niy 1 depvar 2 node project_y substitute field $njj[2];

# Z-AXIS PROJECTION
fem update solution niy 1 depvar 3 node project_z substitute field $njj[3];

###########################################################################
######################## Project back the front edge corner node 57 ##########

# X-AXIS PROJECTION
fem update solution niy 1 depvar 1 node 57,61 substitute field $njs[1];

# Y-AXIS PROJECTION
fem update solution niy 1 depvar 2 node 57,61 substitute field $njs[2];

# Z-AXIS PROJECTION
fem update solution niy 1 depvar 3 node 57,61 substitute field $njs[3];



