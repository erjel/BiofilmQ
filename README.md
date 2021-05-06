[![Image.sc forum](https://img.shields.io/badge/dynamic/json.svg?label=forum&url=https%3A%2F%2Fforum.image.sc%2Ftags%2Fbiofilmq.json&query=%24.topic_list.tags.0.topic_count&colorB=brightgreen&suffix=%20topics&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABPklEQVR42m3SyyqFURTA8Y2BER0TDyExZ+aSPIKUlPIITFzKeQWXwhBlQrmFgUzMMFLKZeguBu5y+//17dP3nc5vuPdee6299gohUYYaDGOyyACq4JmQVoFujOMR77hNfOAGM+hBOQqB9TjHD36xhAa04RCuuXeKOvwHVWIKL9jCK2bRiV284QgL8MwEjAneeo9VNOEaBhzALGtoRy02cIcWhE34jj5YxgW+E5Z4iTPkMYpPLCNY3hdOYEfNbKYdmNngZ1jyEzw7h7AIb3fRTQ95OAZ6yQpGYHMMtOTgouktYwxuXsHgWLLl+4x++Kx1FJrjLTagA77bTPvYgw1rRqY56e+w7GNYsqX6JfPwi7aR+Y5SA+BXtKIRfkfJAYgj14tpOF6+I46c4/cAM3UhM3JxyKsxiOIhH0IO6SH/A1Kb1WBeUjbkAAAAAElFTkSuQmCC)](https://forum.image.sc/tags/biofilmq)
# BiofilmQ: image analysis of microbial biofilm communities

Current release: BiofilmQ v0.2.2 (21 Oct 2020). 

On this GitHub page you can download the BiofilmQ software:
- BiofilmQ.zip (recommended, requires Matlab license, runs on Win10, MacOS, Linux)
- BiofilmQ.exe (does not require Matlab license, runs on Win10). 
- Other download options, example data, installation guide are all here: https://drescherlab.org/data/biofilmQ/docs/usage/installation.html

The documentation for how to use & install can be found here: https://drescherlab.org/data/biofilmQ/docs/ 

Video tutorials for BiofilmQ can be found here: https://drescherlab.org/data/biofilmQ/docs/usage/video_tutorials.html 

Forum for BiofilmQ (ask questions, tell us about bugs/problems!): https://forum.image.sc/tags/biofilmq 

# Build
The project files for the binary builds are stored in `deployment`
## Build Windows 10 binary 
### deploytool
```
cd deployment
deploytool -build BiofilmQ_Win10.prj
```
The files are created in a new folder in `deployment/BiofilmQ_Win10`

### mcc
i.e. in a PowerShell promt
```PowerShell
cd deployment
mkdir build
mkdir build 
mcc -o BiofilmQ -W main:BiofilmQ -T link:exe -d build -v ..\BiofilmQ.m -a ..\includes\about.m -a '..\includes\biofilm analysis' -a ..\BiofilmQ.m -a ..\includes\biofilmQ_version.txt -a ..\includes\deconvolution -a ..\includes\export -a '..\includes\file handling' -a ..\includes\functionality -a ..\includes\help\gridding.png -a ..\includes\help -a '..\includes\image processing' -a '..\includes\image registration' -a ..\includes\help\labels.png -a ..\includes\layout -a ..\includes\layout\logo.png -a ..\includes\layout\logo_large.png -a ..\includes\help\none.png -a '..\includes\object processing' -a ..\includes\performance -a ..\includes\layout\splashScreen\animation\splash01.png -a ..\includes\layout\splashScreen\animation\splash02.png -a ..\includes\layout\splashScreen\animation\splash03.png -a ..\includes\layout\splashScreen\animation\splash04.png -a ..\includes\layout\splashScreen\animation\splash05.png -a ..\includes\layout\splashScreen\animation\splash06.png -a ..\includes\layout\splashScreen\animation\splash07.png -a ..\includes\layout\splashScreen\animation\splash08.png -a ..\includes\layout\splashScreen\animation\splash09.png -a ..\includes\layout\splashScreen\animation\splash10.png -a ..\includes\layout\splashScreen\animation\splash11.png -a ..\includes\layout\splashScreen\animation\splash12.png -a ..\includes\layout\splashScreen\animation\splash13.png -a ..\includes\layout\splashScreen\animation\splash14.png -a ..\includes\layout\splashScreen\animation\splash15.png -a ..\includes\layout\splashScreen\animation\splash16.png -a ..\includes\layout\splashScreen\animation\splash17.png -a ..\includes\layout\splashScreen\animation\splash18.png -a ..\includes\layout\splashScreen\animation\splash19.png -a ..\includes\layout\splashScreen\animation\splash20.png -a ..\includes\layout\splashScreen\animation\splash21.png -a ..\includes\layout\splashScreen\animation\splash22.png -a ..\includes\layout\splashScreen\animation\splash23.png -a ..\includes\layout\splashScreen\animation\splash24.png -a '..\includes\object processing\actions\user-defined parameters\template.m' -a ..\includes\tools -a ..\includes\layout\welcome.html -r BiofilmQ_Win10_resources\icon.ico 
```

The executable is created in `deployment/build`