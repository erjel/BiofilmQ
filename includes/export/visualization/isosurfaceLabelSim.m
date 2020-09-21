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
function cells = isosurfaceLabelSim(objects, resolution, custom_fields, params)
fprintf(' - step 1: creating isosurfaces (elliptical representation)');
ticValue = displayTime;
fprintf('\n');

M = cell(1, numel(objects.stats));
goodObjects = objects.goodObjects;
h = ProgressBar(round(numel(objects.stats)/20));
parfor cellID = 1:numel(objects.stats)
    if ~mod(cellID, 20)
        h.progress;
    end
    if goodObjects(cellID)
      coords = objects.stats(cellID).Centroid;
      evecs = objects.stats(cellID).Orientation_Matrix;
      length = objects.stats(cellID).Shape_Length / (objects.params.scaling_dxy/1000);
      height = objects.stats(cellID).Shape_Height / (objects.params.scaling_dxy/1000);
      width = objects.stats(cellID).Shape_Width / (objects.params.scaling_dxy/1000);
      X = coords';
      [x, y, z, ~] = ellipsoid_plot_analysis(X, evecs(:, 1), evecs(:, 2), evecs(:, 3), ...
          length / 2, height / 2, width / 2);
      
      M{cellID} = surf2patch(x,y,z, 'triangles');
      
      if resolution < 1
          M{cellID} = reducepatch(M{cellID}, resolution);
      end
    end
end
h.stop;
fprintf('         %d cells processed', sum(goodObjects));

counter = 1;
verticesLength = 0;
facesLength = 0;

for i = 1:numel(M)
    if ~isempty(M{i})
        if counter > 1
            verticesLength(counter) = verticesLength(counter-1) + size(M{i}.vertices,1);
            facesLength(counter) = facesLength(counter-1) + size(M{i}.faces,1);
        else
            verticesLength(counter) = size(M{i}.vertices,1);
            facesLength(counter) = size(M{i}.faces,1);
        end
        counter = counter + 1;
    end
end

verticesLengthTotal = verticesLength(end);
facesLengthTotal = facesLength(end);
cells.vertices = zeros(verticesLengthTotal, 3);
cells.faces = zeros(facesLengthTotal, 3);

counter = 1;


for i = 1:numel(custom_fields)
    cells.(custom_fields{i}) = zeros(verticesLengthTotal,1);
end

errorMsg = 0;
for i = 1:numel(M)
    if ~isempty(M{i})
        numFaces(counter) = size(M{i}.faces,1);
        numVertices(counter) = size(M{i}.vertices,1);
        
        if counter > 1
            add = add+numVertices(counter-1);
        else
            add = 0;
        end
        
        if counter > 1
            cells.faces(facesLength(counter-1)+1:facesLength(counter),:) = M{i}.faces+add;
            cells.vertices(verticesLength(counter-1)+1:verticesLength(counter),:) = M{i}.vertices;
        else
            cells.faces(1:facesLength(counter), :) = M{i}.faces+add;
            cells.vertices(1:verticesLength(counter), :) = M{i}.vertices;
        end
        
        
        
        
        
        for j = 1:numel(custom_fields)
            switch custom_fields{j}
                case 'ID'
                    customVar = counter;
                case 'Distance_FromSubstrate'
                    customVar = objects.stats(i).Centroid(3)*objects.params.scaling_dxy/1000;
                case 'RandomNumber'
                    customVar = 1000*rand;
                    
                otherwise
                    if isfield(objects.stats, custom_fields{j})
                        customVar = objects.stats(i).(custom_fields{j});
                    else
                        disp(['Field, "',custom_fields{j},'" not found!']);
                    end
            end
            
            
            
            try
                if counter > 1
                    cells.(custom_fields{j})(verticesLength(counter-1)+1:verticesLength(counter),:) = customVar*ones(size(M{i}.vertices,1),1);
                else
                    cells.(custom_fields{j})(1:verticesLength(counter),:) = customVar*ones(size(M{i}.vertices,1),1);
                end
            catch
                errorMsg = 1;
            end
        end
        
        counter = counter + 1;
    end
end
if errorMsg
    disp('-> An error ocurred!');
end



