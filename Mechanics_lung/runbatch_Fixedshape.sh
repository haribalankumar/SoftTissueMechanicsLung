
read -t 2 -p "I am going to wait for 60 seconds only ..."
mkdir /hpc/hkmu551/Lung/Data/UCSDLungs/Subject06/Prone/Mechanics/IsotropicExpansion

read -t 3 -p "I am going to wait for 60 seconds only ..."
cd /hpc/hkmu551/Lung/Data/UCSDLungs/Subject06/Prone/Mechanics/ 
mv ProneRight100sp4*  DGProneRight8.*  UniExpanProne* D1.* IsotropicExpansion/

read -t 5 -p "I am going to wait for 60 seconds only ..."
rm DGPr* Final* Before* UGPr* Project*

read -t 5 -p "I am going to wait for 60 seconds only ..."
cd /hpc/hkmu551/Lung/FunctionalModels/SoftTissueMechanicsLung/Mechanics_lung

