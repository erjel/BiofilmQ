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
function objects = calculateSubstrateArea(handles, objects,params, filename, layer)

toUm2 = @(voxel, scaling) voxel.*(scaling/1000)^2;


substrateLayer = zeros(objects.ImageSize);
if numel(objects.ImageSize) == 2
    substrateLayer = labelmatrix(objects)>0;
    colonies = regionprops(objects, substrateLayer, 'Area', 'MeanIntensity');
	coverage = num2cell([colonies.Area].*[colonies.MeanIntensity]);
else
    if strcmp(layer, '') || isempty(layer)
        [~, ~, img_raw, ~, params, ~] ...
        = getImageFromRaw(handles, objects, params, filename, params.channel);
        [~, layer] = max(sum(sum(img_raw{params.channel}, 1), 2));
    end
    
    im_layer = round(objects.params.scaling_dz/objects.params.scaling_dxy*layer);
    substrateLayer(:,:,im_layer) = 1;

    try 
        colonies = regionprops3(objects, substrateLayer, 'Volume', 'MeanIntensity');
        coverage = num2cell([colonies.Volume].*[colonies.MeanIntensity]);
    catch ME
        if (strcmp(ME.identifier, 'MATLAB:UndefinedFunction'))
            w = labelmatrix(objects);
            slice = w(:, :, im_layer);
            coverage = num2cell(histc(slice(:), 1:objects.NumObjects));
        else 
            rethrow(ME);
        end
    end

end

[objects.stats.Architecture_LocalSubstrateArea] = coverage{:};
objects.globalMeasurements.Biofilm_SubstrateArea = toUm2(sum([coverage{:}]), objects.params.scaling_dxy);
objects.globalMeasurements.Biofilm_SubstratumCoverage = sum([coverage{:}])/(objects.ImageSize(1)*objects.ImageSize(2));

end




