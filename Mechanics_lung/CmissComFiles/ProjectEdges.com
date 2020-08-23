

# projections for the 'edges'
#############################

fem def data;r;WorkingFiles/CurrentSurfacePoints coupled_nodes;

fem update xi points edge_back faces side2_lung edge free 2 xi1 0 xi3 1 from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];
fem update xi points edge_front faces side2_lung edge free 2 xi1 1 xi3 1 from $njs[1] $njs[2] $njs[3] to_field $njj[1] $njj[2] $njj[3];

