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
function objects = calculateCellProperties(handles, objects, params, filename, index)

parameters = params.cellParametersCalculate;
params.scaling_dxy = objects.params.scaling_dxy;
params.scaling_dz = objects.params.scaling_dz;

for i = 1:size(parameters, 1)
    if parameters{i,2}
        
        fprintf(' - calculating [%s]', parameters{i});
        
        parameters{i,1} = strrep(parameters{i,1}, '?', 'u');
        
        try
            switch lower(parameters{i,1})

                case 'filter objects'
                    objects = filterObjects(handles, objects, params, index);

                case 'remove objects which did not pass filtering'
                    objects = removeBadObjects(objects, params);

                case 'remove objects on the image border'
                    objects = removeObjectsOnBorder(handles, objects, params, filename);

                case 'remove object parameters, option: parameters'
                    objects = removeObjectParameters(handles, objects, parameters{i,3});    

                case 'global biofilm properties'
                    objects = calculateGlobalBiofilmProperties(objects);
                    
                case 'substrate area'
                    objects = calculateSubstrateArea(handles, objects, params, filename, parameters{i,3});

                case 'convexity'
                    objects = calculateConvexity(objects);

                case 'distance to center biofilm'
                    objects = calculateDistanceToCenterOfBiofilm(objects);

                case 'distance to nearest neighbor, option: channel'
                    objects = calculateCell2CellDistance(handles, objects, params, parameters{i,3}, filename);

                case 'distance to surface, option: resolution [vox]'
                    objects = calculateDistanceToSurface(objects, params, parameters{i,3});

                case 'distance to specific object, option: object id'
                    objects = calculateDistanceToObjectID(objects, parameters{i,3});

                case 'local density, option: range [vox]'
                    objects = calculateLocalDensity(objects, parameters{i,3});

                case 'fluorescence properties'
                    objects = calculateFluorescenceProperties(handles, objects, params, filename, parameters{i,3});

                case 'surface properties, option: range [vox]'
                    objects = calculateSurfaceProperties(objects, params, parameters{i,3});
                    
                case 'tag cells'
                    objects = tagCells(objects, params);    

                case 'user-defined parameter'
                    objects = calculateUserDefinedParameter(handles, objects, params, parameters{i,3}, index, filename);     
                    
                
                    
                otherwise
                    warning(['Parameter "', parameters{i,1}, '" not defined']);
            end
        
        catch err
            warning('off','backtrace')
            fprintf('\n');
            warning('ERROR during calculation of module [%s], message: %s', parameters{i,1}, err.message)
            warning('on','backtrace')
        end
    end
end

objects = averageObjectParameters(objects);
objects.stats = orderfields(objects.stats);
objects.globalMeasurements = orderfields(objects.globalMeasurements);


