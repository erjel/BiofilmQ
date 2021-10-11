# How to run unit tests locally
## Run unit tests with same settings as github actions
```
git clone https://github.com/erjel/BiofilmQ.git
cd BiofilmQ
matlab -nosplash -noawt -wait -batch "addpath(pwd); addpath(genpath('tests')); runUnitTests('IncludeSubfolders', true)"
```