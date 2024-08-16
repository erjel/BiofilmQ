# Bumping version
When bumping the version, the new version has to be changed in the following places:
- includes/biofilmQ_version.txt
- deployment/BiofilmQ.prj
- deployment/BiofilmQ_incl_mcr.prj
- docs/conf.py
- docs/usage/installation.rst
- README.md

There is an old MATLAB script that automatizes this for all files based on content of `includes/biofilmQ_version.txt`. It works for the `BiofilmQ*.prj` files, but currently not perfectly for the others...

# Deploying
1. Use the `build_binary_locally.m` script
2. Afterwards, you can rename the created exe and zip files with `rename_files.m` so that they have the currently set version in their name.

# Building Windows executable with mcc
On Windows 10 with Matlab 2022b in PowerShell:
```
mcc -o BiofilmQ -W main:BiofilmQ -T link:exe -d build -v ..\BiofilmQ.m -a ..\includes\about.m -a '..\includes\biofilm analysis' -a ..\BiofilmQ.m -a ..\includes\biofilmQ_version.txt -a ..\includes\deconvolution -a ..\includes\export -a '..\includes\file handling' -a ..\includes\functionality -a ..\includes\help\gridding.png -a ..\includes\help -a '..\includes\image processing' -a '..\includes\image registration' -a ..\includes\help\labels.png -a ..\includes\layout -a ..\includes\layout\logo.png -a ..\includes\layout\logo_large.png -a ..\includes\help\none.png -a '..\includes\object processing' -a ..\includes\performance -a ..\includes\layout\splashScreen\animation\splash01.png -a ..\includes\layout\splashScreen\animation\splash02.png -a ..\includes\layout\splashScreen\animation\splash03.png -a ..\includes\layout\splashScreen\animation\splash04.png -a ..\includes\layout\splashScreen\animation\splash05.png -a ..\includes\layout\splashScreen\animation\splash06.png -a ..\includes\layout\splashScreen\animation\splash07.png -a ..\includes\layout\splashScreen\animation\splash08.png -a ..\includes\layout\splashScreen\animation\splash09.png -a ..\includes\layout\splashScreen\animation\splash10.png -a ..\includes\layout\splashScreen\animation\splash11.png -a ..\includes\layout\splashScreen\animation\splash12.png -a ..\includes\layout\splashScreen\animation\splash13.png -a ..\includes\layout\splashScreen\animation\splash14.png -a ..\includes\layout\splashScreen\animation\splash15.png -a ..\includes\layout\splashScreen\animation\splash16.png -a ..\includes\layout\splashScreen\animation\splash17.png -a ..\includes\layout\splashScreen\animation\splash18.png -a ..\includes\layout\splashScreen\animation\splash19.png -a ..\includes\layout\splashScreen\animation\splash20.png -a ..\includes\layout\splashScreen\animation\splash21.png -a ..\includes\layout\splashScreen\animation\splash22.png -a ..\includes\layout\splashScreen\animation\splash23.png -a ..\includes\layout\splashScreen\animation\splash24.png -a '..\includes\object processing\actions\user-defined parameters\template.m' -a ..\includes\tools -a ..\includes\layout\welcome.html -a '..\includes\additional modules\single cell segmentation\image processing\help\watershedding.png' -a '..\includes\additional modules\seeded watershed 3D\image processing\help\seeded_watershedding.png' -a '..\includes\additional modules' -r BiofilmQ_resources\icon.ico
```
