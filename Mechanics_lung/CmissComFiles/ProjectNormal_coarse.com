
## UPDATE THE GEOMETRY VIA NORMAL PROJECTION
## ------------------------------------------
fem def xi;r;WorkingFiles/LungSurfacePoints coupled_nodes;
fem def data;c from_xi deformed coupled_nodes;
fem def data;w;WorkingFiles/CurrentSurfacePoints coupled_nodes;

for my $j (1..3){ fem update field $njj[$j] substitute solution niy 1 depvar $j; }



###em update xi points edge_front faces side2_lung edge xi1 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
###em update xi points edge_front faces side1_lung edge xi1 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];



#SIDES
#-----------
fem update xi points side1 faces side1_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
fem update xi points side2 faces side2_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

fem update xi points base faces side3_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

fem update xi points base_edge_2 faces side1_lung edge xi2 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
fem update xi points base_edge_1 faces side2_lung edge xi2 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];


## TEMP COMMENT
fem update xi points tops faces top_faces from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];


###fem update xi points base faces side3_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
###fem update xi points base_edge_2 faces side1_lung edge xi2 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
###fem update xi points base_edge_1 faces side2_lung edge xi2 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];


## Edges
## -------------
###em update xi points edge_front faces side2_lung edge xi1 1 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

fem update xi points edge_back faces back_faces from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];


# X-AXIS PROJECTION
# -----------------
fem update solution niy 1 depvar 1 node project_x substitute field $njj[1];

# Y-AXIS PROJECTION
# -----------------
fem update solution niy 1 depvar 2 node project_y substitute field $njj[2];

# Z-AXIS PROJECTION
# -----------------
fem update solution niy 1 depvar 3 node project_z substitute field $njj[3];


# Enforce
# ------------
###fem update solution niy 1 depvar 1 node edge_back substitute field $njs[1];
###fem update solution niy 1 depvar 2 node edge_back substitute field $njs[2];
#####em update solution niy 1 depvar 3 node edge_back substitute field $njs[3];

#em update solution niy 1 depvar 1 node tops substitute field $njs[1];
#em update solution niy 1 depvar 2 node tops substitute field $njs[2];
#em update solution niy 1 depvar 3 node tops substitute field $njs[3];


fem update solution niy 1 depvar 1 node 37 substitute field $njs[1];
fem update solution niy 1 depvar 2 node 37 substitute field $njs[2];
fem update solution niy 1 depvar 3 node 37 substitute field $njs[3];

fem update solution niy 1 depvar 1 node 33 substitute field $njs[1];
fem update solution niy 1 depvar 2 node 33 substitute field $njs[2];
fem update solution niy 1 depvar 3 node 33 substitute field $njs[3];

fem update solution niy 1 depvar 1 node edge_front substitute field $njs[1];
fem update solution niy 1 depvar 2 node edge_front substitute field $njs[2];
fem update solution niy 1 depvar 3 node edge_front substitute field $njs[3];



