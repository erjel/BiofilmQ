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
function objects = calculateSurfaceProperties(objects, params, range)

if ~isfield(objects.stats, 'Cube_CenterCoord')
    fprintf(' -> Does require grid-based segmentation! -> Cancelled.\n');
    return;
end


ticValue = displayTime;

objects = calculateLocalAreaDensity(objects, params, range);

w = labelmatrix(objects)>1;
centerCoord = [objects.stats.Cube_CenterCoord];
centerCoord_x = centerCoord(1:3:end);
centerCoord_y = centerCoord(2:3:end);
centerCoord_z = centerCoord(3:3:end);

[pillars, pID] = unique([centerCoord_x', centerCoord_y'], 'rows');

outline = bwperim(labelmatrix(objects)>0);

surface_perSubstrate = zeros(numel(objects.stats), 1);
surface = zeros(numel(objects.stats), 1);
roughness = zeros(numel(objects.stats), 1);
roughness_L1 = zeros(numel(objects.stats),1);
thickness = zeros(numel(objects.stats),1);
thickness_single = zeros(numel(pID),1);

sX = size(w, 2);
sY = size(w, 1);

for i = 1:numel(pID)
    singlePillar = intersect(find(centerCoord_x == centerCoord_x(pID(i))), find(centerCoord_y == centerCoord_y(pID(i)))); 
    
    
    res = objects.params.gridSpacing;
    x = centerCoord_x(pID(i)) + [-res/2 res/2];
    y = centerCoord_y(pID(i)) + [-res/2 res/2];
    
    if x(2) > sX
        x(2) = sX;
    end
    
    if y(2) > sY
        y(2) = sY;
    end
    
    
    
    
    
    
    

    pillarImage = w(y(1):y(2), x(1):x(2), :);
    
    
    pillarImage_surface = outline(y(1):y(2), x(1):x(2), :);
       
    surface(i) = sum(pillarImage_surface(:));
    
    pillarImage_surface = sum(pillarImage_surface(:))/(size(pillarImage, 1)*size(pillarImage, 2));
    
    surface_perSubstrate(singlePillar) = repmat(pillarImage_surface, numel(singlePillar), 1);
    
    
    
    
    roughness_image = zeros(size(pillarImage, 1), size(pillarImage, 2));
    for h = 1:size(pillarImage, 3)
        roughness_image(pillarImage(:,:,h)>0) = h;
    end
    roughness_image(roughness_image==0) = [];
    roughness_singlePillar = std(roughness_image(:));
    rough_mean = mean(roughness_image(:));
    roughness_singlePillar_l1 = 1/(numel(roughness_image)*rough_mean)*sum(abs(roughness_image(:)-rough_mean));
    
    roughness(singlePillar) = repmat(roughness_singlePillar, numel(singlePillar), 1);
    thickness(singlePillar) = repmat(mean(roughness_image(:)), numel(singlePillar),1);
    roughness_L1(singlePillar) = repmat(roughness_singlePillar_l1, numel(singlePillar),1);
    thickness_single(i) = mean(roughness_image(:));
end
surface_perSubstrate = num2cell(surface_perSubstrate);
[objects.stats.Surface_PerSubstrateArea] = surface_perSubstrate{:};


toUm = @(voxel, scaling) voxel.*(scaling/1000);

thickness = num2cell(toUm(thickness, objects.params.scaling_dxy));
[objects.stats.Surface_LocalThickness] = thickness{:};

thickness_single = toUm(thickness_single, objects.params.scaling_dxy);
meanThickness = mean(thickness_single);
globalRoughness = std(thickness_single); 
globalRoughness_L1 = 1/(numel(thickness_single)*meanThickness)*sum(abs(meanThickness-thickness_single));
objects.globalMeasurements.Biofilm_MeanThickness = meanThickness;
objects.globalMeasurements.Biofilm_Roughness = globalRoughness_L1;

objects.globalMeasurements.Biofilm_OuterSurface = sum(surface);

fprintf('   - other surface properties');
displayTime(ticValue);


