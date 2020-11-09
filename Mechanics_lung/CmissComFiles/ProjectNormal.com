# UPDATE THE GEOMETRY VIA NORMAL PROJECTION
fem de xi;r;WorkingFiles/LungSurfacePoints coupled_nodes;
fem de data;c from_xi deformed coupled_nodes;
fem de data;w;WorkingFiles/CurrentSurfacePoints coupled_nodes;# field $njj[1] $njj[2] $njj[3]; #write out the previous location of the nodes

for my $j (1..3){
    fem update field $njj[$j] substitute solution niy 1 depvar $j;
}
    
#read com;CmissComFiles/ProjectBaseEdge;

#################### Projectecting the middle base  #########################
fem update xi points baseMiddle faces baseMiddleFace from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

# project Base Edges 
#fem update xi points BaseEdge_Side1 faces side1_lung edge free 3 xi2 0 xi3 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
#fem update xi points BaseEdge_Side2 faces side2_lung edge free 3 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

read com;CmissComFiles/ProjectEdges;
read com;CmissComFiles/ProjectTops;
read com;CmissComFiles/ProjectSide;

fem update xi points EdgeNode70_80_89 faces side2_lung edge xi1 0 xi3 1 from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];
fem update xi points EdgeNode70_80_89 faces side2_lung edge xi1 0 xi3 1 from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];

# project Base Edges 
fem update xi points BaseEdge_Side1 faces side1_lung edge xi2 0 xi3 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
fem update xi points BaseEdge_Side2 faces side2_lung edge xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
	
# X-AXIS PROJECTION
fem update solution niy 1 depvar 1 node project_x substitute field $njj[1];
# Y-AXIS PROJECTION
fem update solution niy 1 depvar 2 node project_y substitute field $njj[2];
# Z-AXIS PROJECTION
fem update solution niy 1 depvar 3 node project_z substitute field $njj[3];

###########################################################################
######################## Project back the front edge corner node 57 ##########
fem update solution niy 1 depvar 1 node 57 substitute field $njs[1];
# Y-AXIS PROJECTION
fem update solution niy 1 depvar 2 node 57 substitute field $njs[2];
# Z-AXIS PROJECTION
fem update solution niy 1 depvar 3 node 57 substitute field $njs[3];

