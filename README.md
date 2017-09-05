# SoftTissueMechanicsLung
This repo holds cmiss .com files needed to solve tissue deformation for lung tissue

AIM <br />
To predict deformation of lung tissue using hyperelastic material law

DESCRIPTION <br />
The repo can solve the following:
1) Lung as a simple cuboid shape
2) Lung as tricubic hermite mesh (obtained through geometric fitting from CT imaging data)

It can solve for tissue deformation and stress. It follows either a two-step or three-step procedure.
The two-step procedure is : (isotropic expansion + gravity)
The three-step procedure is : (isotropic expansion + gravity + nonuniform expansion)

RUNNING <br />
These codes (.com) cannot be run on its own. They should be run on a machine which has cmiss-built.

The following tests should be first tested: <br />
PrintInputs --> prints out some important info about subject
RunExpansion --> should be first run alone.
RunExpansion + gravity --> 



EXPECTED OUTPUT


INPUTS <br />
SEDF --> Strain Energy Density Function "W" function parameters 
Subject Upright FRC (From PFT) to Supine FRC (From CT) ratio (default is 100)


OUTPUTS

