
################# Grouping ################################
fem group node 57..96 as all_nodes;
fem group node 57..64,66..68,70..73,75,77..82,84,87..96 as outer_nodes;

fem group elem all as all_elements;
fem group node in elem all_elements as all_nodes;
fem group elem all external s3=0 as s3_0;
fem group elem all external s3=1 as s3_1;
fem group elem all external s2=0 as s2_0;
fem group elem all external s2=1 as s2_1;
fem group elem all external s1=0 as s1_0;
fem group elem all external s1=1 as s1_1;
fem group face all external as contact_cube_face;
fem group face all external as outer_faces;

fem group element 9,10,7,8,3,6,2,5,1,4 as LLL;
fem group element 19,22,18,21,17,20,13,15,11,29,12,30,14,16,27,24,28,23,26 as LUL;


fem group node outer_nodes as project_z;
fem group node outer_nodes as project_y;
fem group node outer_nodes as project_x;



