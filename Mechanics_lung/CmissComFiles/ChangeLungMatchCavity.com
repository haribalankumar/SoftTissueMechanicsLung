fem update solution niy 1 depvar 1 node all_nodes multiply constant $cavity_scale;
fem update solution niy 1 depvar 2 node all_nodes multiply constant $cavity_scale;
fem update solution niy 1 depvar 3 node all_nodes multiply constant $cavity_scale;
