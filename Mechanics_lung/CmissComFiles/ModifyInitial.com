

fem update field $x0 nodes add solution niy 4 depvar 1;
fem update field $y0 nodes add solution niy 4 depvar 2;
fem update field $z0 nodes add solution niy 4 depvar 3;

fem update initial from field $x0 nodes outer_nodes force depvar 1;
fem update initial from field $y0 nodes outer_nodes force depvar 2;
fem update initial from field $z0 nodes outer_nodes force depvar 3;


