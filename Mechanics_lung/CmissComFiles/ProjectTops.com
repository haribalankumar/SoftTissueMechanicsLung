# projections for the 'tops'
fem de data;r;WorkingFiles/CurrentSurfacePoints coupled_nodes;
if ($posture =~ /Supine/){
    fem update xi points top faces side2_lung edge free 1 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
    fem update xi points top_side_1 faces side2_lung edge free 2 xi1 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
    fem update xi points top_side_2 faces side2_lung edge free 1 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
}
if ($posture =~ /Prone/){
    fem update xi points top faces side2_lung edge free 1 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
    fem update xi points top_side_1 faces side2_lung edge free 1 xi2 0 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
    fem update xi points top_side_2 faces side2_lung edge free 2 xi1 1 xi3 0 from $njs[1] $njs[2] $njs[3] to $njj[1] $njj[2] $njj[3];
}
if ($posture =~ /Upright/){ #No projection
}

    
