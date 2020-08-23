fem de data;r;WorkingFiles/CurrentSurfacePoints coupled_nodes;
fem update xi points side1 faces side1_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
fem update xi points side2 faces side2_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
fem update xi points base faces side3_lung from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];

