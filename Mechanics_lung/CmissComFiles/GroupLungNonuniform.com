
###############################################################################
################## Grouping lung ##############################################

fem group node 57..96 as all_nodes reg 1;
fem group node 57..64,66..68,70..73,75,77..82,84,87..96 as outer_nodes;
fem group elem all as all_elements;
fem group node in elem all_elements as all_nodes;
fem group elem all external s3=0 as s3_0;
fem group elem all external s3=1 as s3_1;
fem group elem all external s2=0 as s2_0;
fem group elem all external s2=1 as s2_1;
fem group elem all external s1=0 as s1_0;
fem group elem all external s1=1 as s1_1;

fem group node 61,57 as base_tip;
fem group node 57,61,96 as Fixed_nodes;
#fem group node 57,61 as outer_nodes_WithoutSides;
fem group node 57,61 as TopAndBottom;

fem group node 71..73,77..79,81..82,87..88,90..91,93..94 as Sides_Without_Corner exclude 88,82,73,78;

fem group node 72,78,82,88 as LOblique_fissure;

fem group node 90,93,91,94,88,87,82,81,79,73,78,72 as BothsidesTop;
fem group node 90,91,81,82,73,72 as Side2Top; 
fem group node 93,94,88,87,79,78 as Side1Top;  
fem group node 70,80,89 as EdgeNode70_80_89;
fem group node 95 as EdgeNode95;
fem group node 75 as EdgeNode75;
fem group node 92 as EdgeNode92;
fem group node 84 as EdgeNode84;
fem group node 96 as EdgeNode96;
fem group node 92,75 as EdgeNode92_75;
fem group node 69,76,86 as InnernodesDerivFixed;

fem group node 61,57 as base_tip;


fem group node 57..61,70..73,75,80..82,84,89..92,95..96 as side2 exclude base_tip;
fem group node 57,61,66..68,70,75,77..80,84,87..89,92..96 as side1 exclude base_tip;

fem group face 18,22,25,32,37,56,59,73,76,78,88,90..91,94..95 as side1_lung;
fem group face 4,9,13,28,34,41,44,48,51,62,66,69,80,83,85 as side2_lung;
fem group face 41,48,56,62,73,80,88,94 as frontaledge_faces;

fem group element 9,10,7,8,3,6,2,5,1,4 as LLL;
fem group element 19,22,18,21,17,20,13,15,11,29,12,30,14,16,27,24,28,23,26 as LUL;


#fem group face all elem s3_1 external xi3 high as side1_lung;
#fem group face all elem s3_0 external xi3 low as side2_lung;
#fem group node in elem s3_0 xi3=0 as side2 exclude base_tip; #mediastinal
#fem group node in elem s3_1 xi3=1 as side1 exclude base_tip; #lateral

 
fem group node 92 as top;
fem group node 57..64,66..68 as base exclude base_tip; 

fem group node 70,80,89 as edge_front;
fem group node 75,84,92 as edge_back;



##fem group node in elem s2_0 xi2=0 as top;
##fem group node in elem s2_1 xi2=1 as base exclude base_tip;
##fem group node in elem s1_0 xi1=0 as edge_back exclude base_tip;
##fem group node in elem s1_1 xi1=1 as edge_front exclude base_tip;

##em group node side1,side2,base as outer_nodes;
fem group node side1,side2,base,base_tip as all_outer_nodes;
fem group face all external as contact_cube_face;
fem group face all external as outer_faces ;

fem group node 62,63,64 as baseMiddle;
fem group face 3,7,11,17,20,23,39,93 as baseMiddleFace; 

fem group node 66,67,68 as BaseEdge_Side1;
fem group node 58,59,60 as BaseEdge_Side2; 

fem group node BaseEdge_Side1,BaseEdge_Side2,58,66 as BaseEdge_Sides;
fem group face 3,7,11,17,20,23 as side3_lung;


fem group face 3,7,11,17,20,23 as side3_lung;

#fem group face all elem s2_1 external xi2 high as side3_lung;

fem group node side1,side2 as side;
fem group elem all external s3=0 as s3_0;
fem group elem all external s3=1 as s3_1;
fem group elem all external s2=1 as s2_1;

fem group node 57..64,66..68 as xi2_1 exclude base_tip;

fem group node in elem s3_0 xi3=0 as xi3_0 exclude base_tip;
fem group node in elem s3_1 xi3=1 as xi3_1 exclude base_tip;
###fem group node in elem s2_1 xi2=1 as xi2_1 exclude base_tip;

fem group node 58,62,65..66,71,74,77,81,86..87,90,93,95 as xi1_1 exclude base_tip;
fem group node 60,64,68..69,73,79,82..83,85,88,91,94,96 as xi1_0 exclude base_tip;


#fem group node in elem s1_0 xi1=1 as xi1_1 exclude base_tip;
#fem group node in elem s1_1 xi1=0 as xi1_0 exclude base_tip;

fem group node common side1 and xi1_0 as line_fix;
fem group node common side2 and base as base_edge_1;
fem group node common side1 and base as base_edge_2;

fem group node 95 as top_side_1;
fem group node 96 as top_side_2;

##em group node common top and edge_back as top_side_1;
##em group node common top and edge_front as top_side_2;

fem group node edge_front as edge_front exclude top_side_2;
fem group node edge_back as edge_back exclude top_side_1;

fem group node all_nodes as inner_nodes exclude all_outer_nodes;

fem group node outer_nodes as project_z;
fem group node outer_nodes as project_y;
fem group node outer_nodes as project_x;

fem group face all external as contact_cube_face;
fem group face all external as outer_faces;
##############################################
