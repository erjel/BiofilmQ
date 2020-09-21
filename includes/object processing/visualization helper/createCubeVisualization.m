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

sY = size(img_labeled, 1);
sX = size(img_labeled, 2);

X = res/2+1:res:sX+res/2;
Y = res/2+1:res:sY+res/2;

sZ = size(img_labeled, 3);
Z = res/2+1:res:sZ+res/2-1;

counter = 1;

for z = Z
    for x = X
        for y = Y
            
            Xfrac = x-res/2:x+res/2-1;
            Yfrac = y-res/2:y+res/2-1;
            Zfrac = z-res/2:z+res/2-1;
            
            Xfrac(Xfrac>sX) = [];
            Yfrac(Yfrac>sY) = [];
            Zfrac(Zfrac>sZ) = [];
            Xfrac(Xfrac<1) = [];
            Yfrac(Yfrac<1) = [];
            Zfrac(Zfrac<1) = [];
                
            current_cube = img_labeled(Yfrac, Xfrac, Zfrac);
            
            if any(current_cube(:))
                img(Yfrac, Xfrac, Zfrac) = counter;
                counter = counter + 1;
            end
            
        end
    end
end

objects_cubeOutline = conncomp(img);
objects_cubeOutline.stats = regionprops(objects_cubeOutline);

f1 = fieldnames(objects_cubeOutline.stats);
f2 = fieldnames(objects.stats);
for i = 1:numel(f2)
    if ~any(strcmp(f1, f2{i}))
        [objects_cubeOutline.stats.(f2{i})] = objects.stats.(f2{i});
    end
end

objects_cubeOutline.goodObjects = true(1, objects_cubeOutline.NumObjects);
outlines = isosurfaceLabel(labelmatrix(objects_cubeOutline), objects_cubeOutline, 1, union({'ID', 'RandomNumber'}, f2), objects.params);
mvtk_write(outlines,fullfile(handles.settings.directory, 'data', 'cubes.vtk'), 'legacy-binary',union({'ID', 'RandomNumber'}, f2));


