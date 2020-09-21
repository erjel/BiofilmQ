%%
% BiofilmQ
%
% Copyright (c) 2020 Raimo Hartmann, Hannah Jeckel, and Eric Jelli <biofilmQ@gmail.com>
% Copyright (c) 2020 Drescher-lab, Max Planck Institute for Terrestrial Microbiology, Marburg, Germany
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%

img = zeros(objects.ImageSize);
img_labeled = labelmatrix(objects) > 0;

res = objects.params.gridSpacing;

sY = size(img_labeled, 2);
sX = size(img_labeled, 1);

X = 1:res:sX;
Y = 1:res:sY;

sZ = size(img_labeled, 3);
Z = 1:res:sZ;

counter = 1;
for z = Z
    for x = X
        for y = Y
            
            
            Xfrac = x-res/2:x+res/2-1;
            Yfrac = y;
            Zfrac = z;
            
            Xfrac(Xfrac>sX) = [];
            Yfrac(Yfrac>sY) = [];
            Zfrac(Zfrac>sZ) = [];
            Xfrac(Xfrac<1) = [];
            Yfrac(Yfrac<1) = [];
            Zfrac(Zfrac<1) = [];

            img(Xfrac, Yfrac, Zfrac) = true;
            
            Xfrac = x;
            Yfrac = y;
            Zfrac = z-res/2:z+res/2-1;
            
            Xfrac(Xfrac>sX) = [];
            Yfrac(Yfrac>sY) = [];
            Zfrac(Zfrac>sZ) = [];
            Xfrac(Xfrac<1) = [];
            Yfrac(Yfrac<1) = [];
            Zfrac(Zfrac<1) = [];

            img(Xfrac, Yfrac, Zfrac) = true;
            
            Xfrac = x;
            Yfrac = y-res/2:y+res/2-1;
            Zfrac = z;
            
            Xfrac(Xfrac>sX) = [];
            Yfrac(Yfrac>sY) = [];
            Zfrac(Zfrac>sZ) = [];
            Xfrac(Xfrac<1) = [];
            Yfrac(Yfrac<1) = [];
            Zfrac(Zfrac<1) = [];

            img(Xfrac, Yfrac, Zfrac) = counter;
            counter = counter + 1;
            
        end
    end
end

img(~img_labeled) = 0;

objects_cubeOutline = conncomp(img);
objects_cubeOutline.stats = regionprops(objects_cubeOutline);
objects_cubeOutline.goodObjects = true(1, objects_cubeOutline.NumObjects);
outlines = isosurfaceLabel(labelmatrix(objects_cubeOutline), objects_cubeOutline, 1, {'ID'}, objects.params);
mvtk_write(outlines,fullfile(handles.settings.directory, 'data', 'outlines.vtk'), 'legacy-binary',{});


