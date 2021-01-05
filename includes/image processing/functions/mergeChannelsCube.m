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


function objects_merged = mergeChannelsCube(objects, channelArray, res)
fprintf(' - merging gridded data...\n');

N = numel(objects);
all_ = N + 1;

objects_ = objects{1}; 

w = false([all_, objects_.ImageSize]);
w(1, :, :, :) = labelmatrix(objects_);


for i = 2:N
    w(i, :, :, :) = labelmatrix(objects{i});
end


w(all_, :, :, :) = any(w(1:N, :, :, :), 1);
        
objects_merged = cubeSegmentation(squeeze(w(all_, :, :, :)), res);

if numel(objects_merged.ImageSize)==2
    centroids = cellfun(@(x) [x 1], {objects_merged.stats.Centroid}, 'UniformOutput', false);
    [objects_merged.stats.Centroid] = centroids{:};
    boundingBoxes = cellfun(@(x) [x(1:2) 0.5 x(3:4) 1], {objects_merged.stats.BoundingBox}, 'UniformOutput', false);
    [objects_merged.stats.BoundingBox] = boundingBoxes{:};
end
    
numObjects = objects_merged.NumObjects;

relativeAbundance = zeros(N, numObjects);
overlap3D = zeros(N*(N-1)/2, numObjects);

for i =1:numObjects
    
    
    bbx =  objects_merged.stats(i).BoundingBox;
    bbx = bbx + [0.5 0.5 0.5 -1 -1 -1];
    
    w_ = false(all_, prod(bbx(4:end)+1));
    w_(all_, :) = reshape( w(all_, ...
                        bbx(2):bbx(2)+bbx(5), ...
                        bbx(1):bbx(1)+bbx(4), ...
                        bbx(3):bbx(3)+bbx(6)),1,[]);
    j = 1;
    for ch1 = 1:N
        w_(ch1, :) = reshape( ...
                    w(ch1, ...
                        bbx(2):bbx(2)+bbx(5), ...
                        bbx(1):bbx(1)+bbx(4), ...
                        bbx(3):bbx(3)+bbx(6)),1,[]);
        relativeAbundance(ch1, i) = sum(w_(ch1,:))/ sum(w_(all_,:));
        
        for ch2 = 1:ch1-1
            overlap3D(j, i) = sum(w_(ch1,:) & w_(ch2,:)) / sum(w_(ch1,:) | w_(ch2,:));
            j = j + 1;
        end
    end
end

relativeAbundance = relativeAbundance * 100;

overlap3D = overlap3D * 100;
overlap3D(isnan(overlap3D)) = 0;



for i = 1:N
    relativeAbundance_ = num2cell(relativeAbundance(i, :));
    [objects_merged.stats.(sprintf('Cube_RelativeAbundance_ch%d', channelArray(i)))] = relativeAbundance_{:};
    
    counter = 1;
    for j = 1:i-1
        
        overlap3D_ = num2cell(overlap3D(counter, :));
        [objects_merged.stats.(sprintf('Cube_Overlap3D_ch%d_ch%d', channelArray(i), channelArray(j)))] = overlap3D_{:};

        counter = counter + 1;
    end
end


return
end


